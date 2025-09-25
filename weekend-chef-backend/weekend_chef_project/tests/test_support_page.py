from django.test import TestCase
from django.urls import reverse


class SupportFaqViewTests(TestCase):
    def test_support_faq_page_renders(self):
        response = self.client.get(reverse('support_faq'))
        self.assertEqual(response.status_code, 200)
        self.assertContains(response, 'Help Centre')
        self.assertContains(response, 'support@weekendchef.app')
