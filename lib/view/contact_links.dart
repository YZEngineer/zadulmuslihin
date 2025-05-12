import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactLinksPage extends StatelessWidget {
  // نموذج لروابط التواصل الاجتماعي
  final List<SocialMediaLink> socialLinks = [
    SocialMediaLink(
      title: 'تويتر',
      username: '@zadulmuslihin',
      url: 'https://twitter.com/zadulmuslihin',
      iconData: Icons.flutter_dash,
      color: Colors.blue,
    ),
    SocialMediaLink(
      title: 'انستغرام',
      username: '@zadulmuslihin',
      url: 'https://instagram.com/zadulmuslihin',
      iconData: Icons.camera_alt,
      color: Colors.pink,
    ),
    SocialMediaLink(
      title: 'يوتيوب',
      username: 'زاد المصلحين',
      url: 'https://youtube.com/zadulmuslihin',
      iconData: Icons.play_circle_filled,
      color: Colors.red,
    ),
    SocialMediaLink(
      title: 'تيليجرام',
      username: '@zadulmuslihin',
      url: 'https://t.me/zadulmuslihin',
      iconData: Icons.send,
      color: Colors.blue.shade700,
    ),
    SocialMediaLink(
      title: 'الموقع الإلكتروني',
      username: 'zadulmuslihin.com',
      url: 'https://zadulmuslihin.com',
      iconData: Icons.language,
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تواصل معنا'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('حسابات التواصل الاجتماعي'),
            SizedBox(height: 16),
            _buildSocialLinks(),
            SizedBox(height: 32),
            _buildSectionTitle('اتصل بنا'),
            SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.email,
              title: 'البريد الإلكتروني',
              subtitle: 'contact@zadulmuslihin.com',
              onTap: () => _launchUrl('mailto:contact@zadulmuslihin.com'),
            ),
            SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.phone,
              title: 'هاتف',
              subtitle: '+966 12 345 6789',
              onTap: () => _launchUrl('tel:+966123456789'),
            ),
            SizedBox(height: 32),
            _buildSectionTitle('عن التطبيق'),
            SizedBox(height: 16),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'زاد المصلحين',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'تطبيق زاد المصلحين هو مشروع غير ربحي يهدف إلى نشر المحتوى الإسلامي المفيد بطريقة سهلة وميسرة. نسعى من خلال هذا التطبيق إلى تقديم العديد من الخدمات والأدوات المفيدة للمسلمين في حياتهم اليومية.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'الإصدار: 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Column(
      children: socialLinks.map((link) => _buildSocialLinkCard(link)).toList(),
    );
  }

  Widget _buildSocialLinkCard(SocialMediaLink link) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchUrl(link.url),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: link.color.withOpacity(0.2),
            child: Icon(link.iconData, color: link.color),
          ),
          title: Text(link.title),
          subtitle: Text(link.username),
          trailing: Icon(Icons.open_in_new),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.2),
            child: Icon(icon, color: Colors.green),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  void _launchUrl(String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        print('لا يمكن فتح الرابط: $urlString');
      }
    } catch (e) {
      print('خطأ في فتح الرابط: $e');
    }
  }
}

class SocialMediaLink {
  final String title;
  final String username;
  final String url;
  final IconData iconData;
  final Color color;

  SocialMediaLink({
    required this.title,
    required this.username,
    required this.url,
    required this.iconData,
    required this.color,
  });
}
