import 'package:flutter/material.dart';
import 'package:imarket/main.dart';
import 'package:imarket/presentation/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:imarket/services/theme_provider.dart';
import 'legal_content_screen.dart';
import 'change_password_screen.dart';
import 'account_settings_screen.dart';
import 'coming_soon_screen.dart';
import 'blocked_users_screen.dart'; // استيراد شاشة المستخدمين المحظورين

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              _buildSettingsSection(
                items: [
                  _buildPickerItem(
                    icon: Icons.public,
                    title: 'الدولة',
                    value: 'الأردن 🇯🇴',
                    onTap: () {
                      // يمكن إضافة منطق تغيير الدولة مستقبلاً
                    },
                  ),
                  _buildSwitchItem(
                    icon: Icons.nightlight_round,
                    title: 'الوضع الليلي',
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsSection(
                items: [
                  _buildNavigationItem(
                    icon: Icons.block,
                    title: 'المستخدمين المحظورين',
                    onTap: () => _navigateTo(const BlockedUsersScreen()),
                  ),
                  _buildNavigationItem(
                    icon: Icons.notifications_none,
                    title: 'إعدادات التنبيهات',
                    onTap: () => _navigateTo(const ComingSoonScreen(featureName: 'إعدادات التنبيهات')),
                  ),
                  _buildNavigationItem(
                    icon: Icons.person_outline,
                    title: 'إعدادات الحساب',
                    onTap: () => _navigateTo(const AccountSettingsScreen()),
                  ),
                  _buildNavigationItem(
                    icon: Icons.lock_outline,
                    title: 'تعديل كلمة المرور',
                    onTap: () => _navigateTo(const ChangePasswordScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSettingsSection(
                items: [
                  _buildNavigationItem(
                    icon: Icons.description_outlined,
                    title: 'إتفاقية الاستخدام',
                    onTap: () => _navigateTo(const LegalContentScreen(
                      title: 'إتفاقية الاستخدام',
                      content: '''
مرحبًا بك في iMarket JO.

باستخدامك لتطبيقنا، فإنك توافق على الالتزام بهذه الشروط والأحكام. الرجاء قراءتها بعناية.

1. قبول الشروط
بتسجيل حساب أو استخدام التطبيق، فإنك تقر بأنك قد قرأت وفهمت ووافقت على هذه الاتفاقية. إذا كنت لا توافق على هذه الشروط، يجب عليك عدم استخدام التطبيق.

2. استخدام التطبيق
- يجب أن يكون عمرك 18 عامًا على الأقل لإنشاء حساب ونشر إعلانات.
- أنت المسؤول الوحيد عن الحفاظ على أمان كلمة المرور الخاصة بك وعن جميع الأنشطة التي تحدث تحت حسابك.
- يُستخدم التطبيق لغرض عرض وبيع وشراء أجهزة iPhone المستعملة والجديدة فقط.

3. مسؤوليات المستخدم
- أنت المسؤول الوحيد عن دقة وصحة المعلومات الواردة في إعلاناتك، بما في ذلك السعر والمواصفات والحالة والصور.
- يُمنع نشر أي محتوى مضلل أو احتيالي أو ينتهك حقوق الملكية الفكرية للآخرين.
- iMarket JO هو منصة وسيطة تربط بين البائعين والمشترين. نحن لسنا طرفًا في أي معاملة بيع أو شراء تتم بين المستخدمين.
- نحن لا نضمن جودة أو سلامة أو قانونية الأجهزة المُعلن عنها. تتم جميع المعاملات على مسؤولية الأطراف المعنية.

4. المحتوى المحظور
يُمنع منعًا باتًا نشر إعلانات تحتوي على:
- سلع مسروقة أو غير قانونية.
- معلومات اتصال مزيفة.
- صور غير حقيقية أو مأخوذة من الإنترنت لا تمثل الجهاز الفعلي.
- أي محتوى يهدف إلى التشهير أو الإساءة أو التحرش بمستخدمين آخرين.

5. النقاط والخدمات المدفوعة
- يوفر التطبيق "نقاط تمييز" يمكن استخدامها لميزات إضافية مثل تمييز الإعلانات أو رفعها.
- قد تكون هذه النقاط مجانية عند التسجيل أو يتم شراؤها.
- جميع عمليات شراء النقاط نهائية وغير قابلة للاسترداد.

6. إخلاء المسؤولية
- يتم توفير التطبيق "كما هو" دون أي ضمانات من أي نوع.
- نحن غير مسؤولين عن أي خسائر أو أضرار مباشرة أو غير مباشرة قد تنشأ عن استخدامك للتطبيق أو عن أي معاملات بين المستخدمين.

7. إنهاء الحساب
نحتفظ بالحق في تعليق أو حذف أي حساب يخالف هذه الشروط دون سابق إنذار.

8. تعديل الشروط
قد نقوم بتحديث هذه الشروط من وقت لآخر. سنقوم بإعلامك بأي تغييرات جوهرية. استمرارك في استخدام التطبيق بعد التحديثات يعني موافقتك على الشروط الجديدة.

9. القانون الحاكم
تخضع هذه الاتفاقية وتُفسر وفقًا لقوانين المملكة الأردنية الهاشمية.

للاستفسارات، يرجى التواصل معنا.
''',
                    )),
                  ),
                  _buildNavigationItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'سياسة الخصوصية',
                    onTap: () => _navigateTo(const LegalContentScreen(
                      title: 'سياسة الخصوصية',
                      content: '''
توضح سياسة الخصوصية هذه كيف يقوم تطبيق iMarket JO بجمع واستخدام وحماية معلوماتك الشخصية.

1. المعلومات التي نجمعها
أ. المعلومات التي تقدمها لنا مباشرةً:
- عند إنشاء حساب: نجمع اسمك الكامل، عنوان بريدك الإلكتروني، ورقم هاتفك.
- عند نشر إعلان: نجمع تفاصيل الجهاز الذي تعلن عنه، بما في ذلك الصور والسعر والوصف.
- عند ترك مراجعة: نجمع تقييمك والتعليق الذي تكتبه.

ب. المعلومات التي نجمعها تلقائيًا:
- قد نقوم بجمع معلومات غير شخصية حول كيفية تفاعلك مع التطبيق لتحسين خدماتنا.

2. كيف نستخدم معلوماتك
نستخدم المعلومات التي نجمعها للأغراض التالية:
- لإنشاء وإدارة حسابك.
- لعرض إعلاناتك للمستخدمين الآخرين.
- لتمكين التواصل بين البائعين والمشترين (عبر عرض رقم الهاتف في الإعلان).
- لتحسين وتخصيص تجربة استخدام التطبيق.
- لإدارة نظام التقييمات والمراجعات.
- لإرسال إشعارات هامة تتعلق بحسابك أو خدماتنا.

3. مشاركة المعلومات
نحن لا نبيع أو نؤجر معلوماتك الشخصية لأطراف ثالثة. قد نشارك معلوماتك في الحالات التالية فقط:
- مع المستخدمين الآخرين: يتم عرض اسمك ورقم هاتفك الموجود في الإعلان للمستخدمين الآخرين لتسهيل عملية البيع والشراء.
- مع مزودي الخدمات: نستخدم خدمات طرف ثالث مثل Supabase لتوفير البنية التحتية للتطبيق. هؤلاء المزودون ملزمون بالحفاظ على سرية معلوماتك.
- لأسباب قانونية: إذا طُلب منا ذلك بموجب أمر قضائي أو للامتثال للقوانين المعمول بها.

4. أمان البيانات
نتخذ إجراءات أمنية معقولة لحماية معلوماتك من الوصول غير المصرح به أو التغيير أو الكشف. ومع ذلك، لا توجد طريقة نقل عبر الإنترنت أو تخزين إلكتروني آمنة بنسبة 100%.

5. حقوقك
لديك الحق في الوصول إلى معلوماتك الشخصية وتحديثها في أي وقت من خلال شاشة "إعدادات الحساب". يمكنك أيضًا حذف حسابك بالكامل، مما سيؤدي إلى حذف بياناتك المرتبطة به.

6. التغييرات على هذه السياسة
قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سيتم إعلامك بأي تغييرات عن طريق نشر السياسة الجديدة داخل التطبيق.

7. اتصل بنا
إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه، يرجى التواصل معنا.
''',
                    )),
                  ),
                  _buildNavigationItem(
                    icon: Icons.help_outline,
                    title: 'المساعدة',
                    onTap: () => _navigateTo(const ComingSoonScreen(featureName: 'المساعدة')),
                  ),
                  _buildNavigationItem(
                    icon: Icons.info_outline,
                    title: 'عن التطبيق',
                    onTap: () => _navigateTo(const ComingSoonScreen(featureName: 'عن التطبيق')),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({required List<Widget> items}) {
    return Card(
      child: Column(children: items),
    );
  }

  Widget _buildNavigationItem(
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(
      {required IconData icon,
      required String title,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildPickerItem(
      {required IconData icon,
      required String title,
      required String value,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text('تسجيل الخروج'),
        onPressed: _signOut,
        style: TextButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}