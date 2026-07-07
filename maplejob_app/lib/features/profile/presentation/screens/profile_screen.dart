import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/config/theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/profile_provider.dart';

import '../../../notifications/presentation/providers/notifications_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          ref.watch(unreadNotificationsCountProvider) > 0
              ? Badge(
                  label: Text(ref.watch(unreadNotificationsCountProvider).toString()),
                  offset: const Offset(-4, 4),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () => context.push('/notifications'),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => context.push('/notifications'),
                ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDCMr3NE6rQKuDjgsGaKlMpqV963XMhtXXZhT1zX_g66Cf7R0fAVSBMiL5tUOk_x8IQXnKACuiVNqwW30AFm7EDGEgNwqthL-mQ6jRr_pOOYwb2907gvqW5yDAI5JoEQRNbZGjEDCRoP9txqoaeKuC7SkandeI4LUW4BlrfgzCi1IKvxvKtXvyJTEQxutTTIhKugqFWdJmcYO2DEWIwY2Gkor5VryDj-tJcU-kFGeTJhbHLq0CQEeDYAA'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: profileState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Profile not loaded.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Profile Card
                _buildHeroCard(context, user),
                const SizedBox(height: 24.0),

                // Responsive layout using Flow/Wrap or Row (Bento columns)
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                _buildPersonalDetailsCard(context, user),
                                const SizedBox(height: 20.0),
                                _buildLinkedInCard(context, user),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20.0),
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                _buildCompletionCard(context, user),
                                const SizedBox(height: 20.0),
                                _buildResumeCard(context, user),
                                const SizedBox(height: 20.0),
                                _buildSkillsCard(context, user),
                                const SizedBox(height: 20.0),
                                _buildEducationCard(context, user),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Stacked layout for mobile
                      return Column(
                        children: [
                          _buildCompletionCard(context, user),
                          const SizedBox(height: 20.0),
                          _buildPersonalDetailsCard(context, user),
                          const SizedBox(height: 20.0),
                          _buildLinkedInCard(context, user),
                          const SizedBox(height: 20.0),
                          _buildResumeCard(context, user),
                          const SizedBox(height: 20.0),
                          _buildSkillsCard(context, user),
                          const SizedBox(height: 20.0),
                          _buildEducationCard(context, user),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
        error: (err, _) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, UserEntity user) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.surfaceContainer,
                  backgroundImage: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuANu0YJmICpwn1BQ6OsmESJYNmE4WwTsJbfVs0tbtbFmI0XnHtCtWtLLA_-Tn7hJd52YF1DrIYKsdHqazRHYFsbHrl0FFQa7qDqOzHtEmX8ifV8rS7lbaEzC9s7f8hgKnn9bPpU_9OcIJjlxZTUGyxzBZhH8IcMiZzsyv28PVUl6iAilHlY5LF9mWJDmHdEs60BO022zWAmhPpDeKhm5bBbhaUP47hccuqvCrbw0mvPs9Rffet_QBXzww'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : 'Applicant Profile',
                        style: AppTheme.titleLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.appliedBg,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      'Active Applicant',
                      style: AppTheme.labelSm.copyWith(color: AppTheme.appliedText, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.outlineColor),
                      const SizedBox(width: 4.0),
                      Text(
                        user.address?.isNotEmpty == true ? user.address! : 'No address set',
                        style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_note, color: AppTheme.secondaryColor, size: 28),
              onPressed: () => context.push('/profile/edit'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context, UserEntity user) {
    final pct = user.completionPercentage;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile Completion', style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor)),
                Text('${pct.toInt()}%', style: AppTheme.titleMd.copyWith(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12.0),
            LinearProgressIndicator(
              value: pct / 100.0,
              backgroundColor: AppTheme.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
              minHeight: 8.0,
              borderRadius: BorderRadius.circular(4.0),
            ),
            const SizedBox(height: 10.0),
            Text(
              'Complete all fields to stand out to employers.',
              style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsCard(BuildContext context, UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Details', style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor)),
            const Divider(height: 24, color: AppTheme.outlineVariantColor),
            _buildDetailTile(Icons.mail_outlined, 'Email', user.email),
            const SizedBox(height: 16.0),
            _buildDetailTile(Icons.phone_outlined, 'Phone', user.phone),
            const SizedBox(height: 16.0),
            _buildDetailTile(
              Icons.cake_outlined,
              'Date of Birth',
              user.dob != null ? DateFormat('MMM dd, yyyy').format(user.dob!) : 'Not set',
            ),
            const SizedBox(height: 16.0),
            _buildDetailTile(Icons.wc_outlined, 'Gender', user.gender ?? 'Not set'),
            const SizedBox(height: 16.0),
            _buildDetailTile(Icons.home_outlined, 'Address', user.address ?? 'Not set'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor)),
              const SizedBox(height: 2.0),
              Text(
                value.isNotEmpty ? value : 'Not set',
                style: AppTheme.bodyMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedInCard(BuildContext context, UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F1FA),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Icon(Icons.link, color: Color(0xFF0077B5)),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LinkedIn Profile', style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor)),
                  const SizedBox(height: 2.0),
                  Text(
                    user.linkedinUrl?.isNotEmpty == true ? user.linkedinUrl! : 'No profile linked',
                    style: AppTheme.bodyMd.copyWith(
                      color: user.linkedinUrl?.isNotEmpty == true ? AppTheme.secondaryColor : AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumeCard(BuildContext context, UserEntity user) {
    final hasResume = user.resumeUrl?.isNotEmpty == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attached Resume', style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor)),
            const Divider(height: 24, color: AppTheme.outlineVariantColor),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.rejectedBg,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: AppTheme.rejectedText),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasResume ? (user.resumeName ?? 'Resume.pdf') : 'No resume uploaded',
                        style: AppTheme.bodyMd.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        hasResume ? 'PDF Only' : 'Upload your resume to apply for jobs',
                        style: AppTheme.labelSm.copyWith(color: AppTheme.outlineColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to resume upload flow
                    context.push('/profile/resume');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(hasResume ? 'Replace' : 'Upload'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard(BuildContext context, UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skills & Expertise', style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor)),
            const Divider(height: 24, color: AppTheme.outlineVariantColor),
            if (user.skills.isEmpty)
              Text('No skills added yet.', style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor))
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: user.skills.map((skill) {
                  return Chip(
                    label: Text(skill, style: AppTheme.labelSm.copyWith(color: AppTheme.primaryColor)),
                    backgroundColor: AppTheme.surfaceContainerLow,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(BuildContext context, UserEntity user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Education', style: AppTheme.titleMd.copyWith(color: AppTheme.primaryColor)),
            const Divider(height: 24, color: AppTheme.outlineVariantColor),
            if (user.education.isEmpty)
              Text('No education history added yet.', style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: user.education.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16.0),
                itemBuilder: (context, index) {
                  final edu = user.education[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Icon(Icons.school_outlined, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${edu.degree} in ${edu.fieldOfStudy}',
                              style: AppTheme.bodyLg.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              edu.school,
                              style: AppTheme.bodyMd.copyWith(color: AppTheme.outlineColor),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              '${edu.startYear} - ${edu.endYear}',
                              style: AppTheme.labelSm.copyWith(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
