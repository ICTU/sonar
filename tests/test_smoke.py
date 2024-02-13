from os import getenv
from unittest import TestCase

from sonarqube import SonarQubeClient


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
