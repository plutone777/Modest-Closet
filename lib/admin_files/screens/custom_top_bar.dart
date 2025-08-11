import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_gradient_background.dart';

class CustomTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomTopBar({super.key, required this.title});

  void _showModeratorGuidelines(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFF9E7E9),
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    '''
🛡️ Modest Closet – Moderator Guidelines
Purpose:
These guidelines are designed to help moderators maintain a safe, respectful, and inspiring environment for Muslim girls and women exploring modest fashion. Moderators are responsible for enforcing community standards, reviewing content, and supporting a positive user experience.

🧕 Core Values to Uphold
Modesty – Promote content that aligns with cultural and Islamic principles of modest dress.

Respect – Maintain a zero-tolerance policy on hate speech, bullying, or harassment.

Privacy – Protect user identity and ensure blurred faces and restricted visibility are respected.

Empowerment – Support users and stylists who inspire others in healthy and meaningful ways.

Inclusivity – Allow diversity in interpretations of modest fashion, as long as it remains respectful.

🔍 Moderator Responsibilities
1. Review and Triage Reports
Review reports made by users (on posts, comments, messages, or accounts).

Prioritize serious issues (e.g. hate speech, harassment).

Use clear labels: Pending, Reviewed, Escalated, or Dismissed.

Respond to every report within 48 hours when possible.

2. Content Moderation
Remove:

Immodest or revealing outfits (e.g. transparent clothing, short skirts, sleeveless tops).

Inappropriate language, offensive comments, or suggestive captions.

Fashion suggestions that contradict the community modesty guidelines.

Allow:

Cultural variations in modest fashion (e.g., traditional ethnic styles).

Hijab-free photos only if the user’s face is blurred or the account is private.

3. User Account Actions
Warn for minor violations (e.g. wrong category).

Temporarily restrict for repeated warnings.

Ban for:

Hate speech

Pornographic or haram content

Spam or bot behavior

Document all actions in the moderation log with justification.

4. Messages and Interactions
When messaging users:

Be polite, brief, and firm.

Always explain the reason for the moderation action.

Offer guidance for future compliance.

5. Community Feed Oversight
Monitor trends and community dynamics.

Ensure stylists uphold their responsibility to guide respectfully.

Approve style tips, hijab tutorials, and lookbooks that reflect modesty values.

6. Face & Privacy Moderation
Ensure that users who select “Blur Face” have their photo processed correctly.

Do not approve posts that show uncovered faces if the user prefers anonymity.

Remove any facial photos shared without consent or incorrectly categorized.

7. Stylists Content Moderation
Stylists are role models; their content must reflect:

Professionalism

Respect for religious and cultural diversity

Clarity in styling advice

Mark content for review if stylist engages in promotional/spammy or non-modest behavior.

8. Report Categories to Watch
Type of Report	Example	Action
Immodest outfit	Transparent shirt, short skirt	Remove post
Harassment/abuse	Insult in comments or private messages	Warn/ban user
Spam or bots	Repeated ads, irrelevant posts	Ban account
False claims	Styling advice with misleading or offensive context	Warn/remove post
Privacy violation	Unblurred face without consent	Remove/notify user

⚠️ Sensitive Areas
Religious Representation: Avoid allowing posts that mock, misrepresent, or exploit religious themes.

Body Positivity: Support body diversity while staying within modest boundaries.

Fashion Innovation: Encourage creativity, but ensure that recommendations do not contradict modest fashion norms.

📊 Weekly Moderator Checklist
✅ Check and resolve pending reports

✅ Review top trending posts

✅ Monitor flagged stylists and influencers

✅ Attend feedback from community members

✅ Update escalation list to admins

🧠 Appeals and Feedback
Users can appeal a moderation decision via the Report Review form.

You must:

Review original post and context

Communicate final decision clearly

Log appeal resolution in the system

💬 Templates for Moderator Messages
Violation Warning:

Salam [User], your recent post has been removed as it does not align with our modesty guidelines. Kindly refer to our posting standards to ensure your future content reflects our values. Thank you for understanding.

Ban Notification:

Your account has been banned due to repeated violations of our modest fashion community standards, including [brief reason]. For further clarification, contact support@modestcloset.com.

Appeal Denied:

Thank you for submitting your appeal. After reviewing your case, the original decision will stand due to [brief explanation]. Please continue to engage with the community respectfully.

🤝 Moderator Conduct
Remain neutral and non-judgmental

Do not engage in arguments; escalate if necessary

Always act with the community’s spiritual and emotional safety in mind

Keep communication confidential and respectful
                    ''',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF412934),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF412934),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAccountMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);

    final value = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + 56, offset.dx + 1, offset.dy + 1),
      color: const Color(0xFFF9E7E9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        PopupMenuItem(
          value: 'account',
          child: Row(
            children: const [
              Icon(Icons.account_circle_outlined, color: Color(0xFF412934)),
              SizedBox(width: 8),
              Text('Account', style: TextStyle(color: Color(0xFF412934))),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, color: Color(0xFF412934)),
              SizedBox(width: 8),
              Text('Log out', style: TextStyle(color: Color(0xFF412934))),
            ],
          ),
        ),
      ],
      elevation: 2,
    );

    if (value == 'logout') {
      await FirebaseAuth.instance.signOut();
      // Go back to login and clear navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
    if (value == 'account') {
      showDialog(
        context: context,
        builder: (context) => const _AccountInfoDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFD3A3AD),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.shield_outlined, color: Color(0xFF412934)),
        onPressed: () => _showModeratorGuidelines(context),
        tooltip: 'Moderator Guidelines',
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF412934),
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
      actions: [
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.person_outline, color: Color(0xFF412934)),
            onPressed: () => _showAccountMenu(ctx),
            tooltip: 'Profile',
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

// ---------------------
// Account Info Dialog with Firestore
// ---------------------

class _AccountInfoDialog extends StatelessWidget {
  const _AccountInfoDialog();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Dialog(
        backgroundColor: Color(0xFFF9E7E9),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            "No user found",
            style: TextStyle(color: Color(0xFF412934)),
          ),
        ),
      );
    }
    final uid = user.uid;

    return Dialog(
      backgroundColor: const Color(0xFFF9E7E9),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: SizedBox(
        width: 340,
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Users').doc(uid).get(),
          builder: (context, snapshot) {
            final userData = snapshot.data?.data() as Map<String, dynamic>?;

            final displayName = userData?['username'] ?? user.displayName ?? "No name";
            final email = userData?['email'] ?? user.email ?? "No email";
            final role = userData?['role'] ?? "—";
            final createdAt = userData?['createdAt'];
            String createdAtStr = "";
            if (createdAt != null) {
              if (createdAt is String) {
                createdAtStr = createdAt;
              } else if (createdAt is Timestamp) {
                createdAtStr = createdAt.toDate().toString();
              } else {
                createdAtStr = createdAt.toString();
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top bar (like post dialog)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD3A3AD),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Account Info",
                        style: TextStyle(
                            color: Color(0xFF412934),
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF412934)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Profile Icon (placeholder if null)
                CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFFD3A3AD),
                  backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: (user.photoURL == null || user.photoURL!.isEmpty)
                      ? const Icon(Icons.person, color: Color(0xFF412934), size: 46)
                      : null,
                ),
                const SizedBox(height: 14),
                Text(
                  displayName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF412934)),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Color(0xFF412934)),
                ),
                const SizedBox(height: 12),
                Text(
                  "Role: $role",
                  style: const TextStyle(fontSize: 13, color: Color(0xFF412934)),
                ),
                const SizedBox(height: 4),
                Text(
                  "UID: $uid",
                  style: const TextStyle(fontSize: 12, color: Color(0xFF85565E)),
                  textAlign: TextAlign.center,
                ),
                if (createdAtStr.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Created: $createdAtStr",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF85565E)),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
