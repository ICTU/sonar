from json import loads
from os import getenv
from unittest import TestCase, skipUnless

import requests
from sonarqube import SonarQubeClient

PROJECT_CODE = getenv("PROJECT_CODE")
PROJECT_RULES = getenv("PROJECT_RULES")
CONFIG_FILE = getenv("CONFIG_FILE", "/src/config.json")


class FunctionalTest(TestCase):
    @classmethod
    def setUpClass(cls):
        """Expose sonar api and credentials to tests."""
        with open(CONFIG_FILE, "r") as config_file:
            cls.config_json = loads(config_file.read())
        sonar_port = getenv("SONAR_PORT", "9000")
        sonar_base_url = f"http://localhost:{sonar_port}"
        sonar_pass = getenv("SONARQUBE_PASSWORD", "admin")
        cls.sonar_client = SonarQubeClient(sonarqube_url=sonar_base_url, username="admin", password=sonar_pass)
        cls.sonar_api = f"{sonar_base_url}/api"
        cls.sonar_auth = ("admin", sonar_pass)

    def _search_profiles(self, **kwargs):
        """Convenience wrapper for sonar api quality profile search."""
        return self.sonar_client.qualityprofiles.search_quality_profiles(**kwargs)

    def _search_rules(self, **kwargs):
        """Convenience wrapper for sonar api rule search."""
        return self.sonar_client.rules.search_rules(**kwargs)
    
    def test_sonar_way_profile_remains(self):
        """Check that the 'Sonar way' profile remains when a profile is defined for the language."""
        java_profiles = self._search_profiles(language="java")
        self.assertIn("Sonar way", [profile["name"] for profile in java_profiles["profiles"]])
        version_profile = f"ictu-{self.config_json['profiles']['java']['version']}-{self.config_json['rules_version']}"
        self.assertIn(version_profile, [profile["name"] for profile in java_profiles["profiles"]])

    @skipUnless(PROJECT_CODE, "PROJECT_CODE was not passed")
    @skipUnless(PROJECT_RULES, "PROJECT_RULES was not passed")
    def test_project_override_profile(self):
        """Check that overridden rule activation is applied."""
        overridden_key = "Web:WhiteSpaceAroundCheck"
        self.assertTrue(any([rule_line == f"+{overridden_key}" for rule_line in PROJECT_RULES.split(";")]))

        version_profile = f"ictu-{self.config_json['profiles']['web']['version']}-{self.config_json['rules_version']}"
        web_profiles = self._search_profiles(
            defaults="true", language="web", qualityProfile=f"{PROJECT_CODE}-{version_profile}"
        )  # also verify that the overridden profile is the default
        web_profile_key = next(profile["key"] for profile in web_profiles["profiles"])
        web_rule = self._search_rules(activation="true", qprofile=web_profile_key, rule_key=overridden_key)
        self.assertEqual(1, web_rule["total"])

        # Verify that it indeed differs from the custom profile
        web_profiles = self._search_profiles(defaults="false", language="web", qualityProfile=version_profile)
        web_profile_key = next(profile["key"] for profile in web_profiles["profiles"])
        web_rule = self._search_rules(activation="false", qprofile=web_profile_key, rule_key=overridden_key)
        self.assertEqual(1, web_rule["total"])

    def test_type_profile(self):
        """Check that custom profile rule type activation is applied."""
        self.assertIn("types=", self.config_json["rules"]["web"][0])
        overridden_key = "Web:ComplexityCheck"
        self.assertFalse(next(overridden_key in rule_line for rule_line in self.config_json["rules"]["web"]))

        version_profile = f"ictu-{self.config_json['profiles']['web']['version']}-{self.config_json['rules_version']}"
        web_profiles = self._search_profiles(language="web", qualityProfile=version_profile)
        web_profile_key = next(profile["key"] for profile in web_profiles["profiles"])
        web_rule = self._search_rules(activation="true", qprofile=web_profile_key, rule_key=overridden_key)
        self.assertEqual(1, web_rule["total"])

        # Verify that it indeed differs from the Sonar way
        sonar_way_web = self._search_profiles(language="web", qualityProfile="Sonar way")
        sonar_way_key = next(p["key"] for p in sonar_way_web["profiles"])
        sonar_way_rule = self._search_rules(activation="false", qprofile=sonar_way_key, rule_key=overridden_key)
        self.assertEqual(1, sonar_way_rule["total"])

    def test_rule_params_in_profile(self):
        """Check that custom profile rule params are applied."""
        cs_param_rule_lines = [rule_line for rule_line in self.config_json["rules"]["cs"] if "|" in rule_line]
        self.assertNotEqual([], cs_param_rule_lines)

        version_profile = f"ictu-{self.config_json['profiles']['cs']['version']}-{self.config_json['rules_version']}"
        cs_profile_search = self._search_profiles(language="cs", qualityProfile=version_profile)
        self.assertEqual(1, len(cs_profile_search["profiles"]))

        # Fetch changelog api with requests, because library does not expose it
        changelog_api = f"{self.sonar_api}/qualityprofiles/changelog"
        change_history_params = {"language": "cs", "qualityProfile": version_profile, "ps": 500}
        api_result = requests.get(changelog_api, auth=self.sonar_auth, params=change_history_params).json()
        self.assertGreater(change_history_params["ps"], api_result["total"])

        # Verify that each param override has a corresponding changelog event
        profile_changes = api_result["events"]
        for cs_rule_line in cs_param_rule_lines:
            rule_key, rule_params_str = cs_rule_line[1:].split()[0].split("|")
            rule_changes = [change for change in profile_changes if change["ruleKey"] == rule_key]
            for rule_param_str in rule_params_str.split(";"):
                rule_params = rule_param_str.split("=")
                param_dict = {rule_params[0]: rule_params[1]}
                self.assertTrue(next(
                    param_dict.items() <= rule_change.get('params', {}).items() for rule_change in rule_changes
                ))

        # Verify that it indeed differs from the Sonar way
        self.assertTrue(next(event for event in profile_changes if event["action"] == "UPDATED"))

    def test_profile_rule_deactivation(self):
        """Check that custom profile rule deactivation is applied."""
        ts_rule_lines = [rule_line for rule_line in self.config_json["rules"]["ts"] if "types=" not in rule_line]
        self.assertTrue(any([rule_line.startswith("-") for rule_line in ts_rule_lines]))
        self.assertTrue(any([rule_line.startswith("+") for rule_line in ts_rule_lines]))

        version_profile = f"ictu-{self.config_json['profiles']['ts']['version']}-{self.config_json['rules_version']}"
        ts_profile_search = self._search_profiles(language="ts", qualityProfile=version_profile)
        ts_profile_key = next(profile["key"] for profile in ts_profile_search["profiles"])

        for ts_rule_line in ts_rule_lines:
            activation = "yes" if ts_rule_line[0] == "+" else "no"
            rule_key = ts_rule_line[1:].split()[0].split("|")[0]
            ts_rule = self._search_rules(activation=activation, qprofile=ts_profile_key, rule_key=rule_key)
            self.assertEqual(1, ts_rule["total"])

        # Verify that it indeed differs from the Sonar way
        sonar_way_ts = self._search_profiles(language="ts", qualityProfile="Sonar way")
        sonar_way_key = next(p["key"] for p in sonar_way_ts["profiles"])
        sonar_way_rule = self._search_rules(qprofile=sonar_way_key, rule_key="swift:S104")
        self.assertEqual(0, sonar_way_rule["total"])  # is not listed as a disabled key
