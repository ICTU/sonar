from os import getenv
from unittest import TestCase, skipUnless

from sonarqube import SonarQubeClient

PROJECT_CODE = getenv("PROJECT_CODE")
PROJECT_RULES = getenv("PROJECT_RULES")


class SonarTest(TestCase):
    def setUp(self) -> None:
        sonar_port = getenv("SONAR_PORT", "9000")
        sonar_base_url = f"http://localhost:{sonar_port}"
        sonar_pass = getenv("SONARQUBE_PASSWORD", "admin")
        self.sonar_client = SonarQubeClient(sonarqube_url=sonar_base_url, username="admin", password=sonar_pass)

    def test_java_profile(self):
        java_quality_profiles = self.sonar_client.qualityprofiles.search_quality_profiles(language="java")
        java_profile_names = [profile["name"] for profile in java_quality_profiles["profiles"]]
        self.assertIn("Sonar way", java_profile_names)

    @skipUnless(PROJECT_CODE, "PROJECT_CODE was not passed")
    def test_csharpsquid_profile(self):
        search_result = self.sonar_client.qualityprofiles.search_quality_profiles(
            defaults="true", language="cs", qualityProfile=f"{PROJECT_CODE}-ictu-cs-profile-v9.13.0-20231222"
        )
        self.assertEqual(len(search_result['profiles']), 1)
        cs_profile_key = search_result['profiles'][0]['key']
        self.assertIsNotNone(cs_profile_key)  # TODO - check activated rules within profile instead

    @skipUnless(PROJECT_CODE, "PROJECT_CODE was not passed")
    def test_ts_profile(self):
        search_result = self.sonar_client.qualityprofiles.search_quality_profiles(
            defaults="true", language="ts", qualityProfile=f"{PROJECT_CODE}-ictu-ts-profile-v10.9.0-20231222"
        )
        self.assertEqual(len(search_result['profiles']), 1)
        ts_profile_key = search_result['profiles'][0]['key']
        self.assertIsNotNone(ts_profile_key)  # TODO - check activated rules within profile instead
