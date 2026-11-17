part of 'update_profile_screen.dart';

class UpdateProfileMobileScreen extends GetView<UpdateProfileController> {
  const UpdateProfileMobileScreen({super.key});

  static const double _heroHeight = 220.0;
  static const double _avatarRadius = 52.0;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: CarboColors.background,
        extendBodyBehindAppBar: true,
        appBar: _buildTransparentAppBar(context),
        bottomNavigationBar: controller.isUpdateLoading
            ? Loader()
            : (controller.isLoading ? null : _buttonWidget(context)),
        // Always render the full body so Hero always plays
        body: _bodyWidget(context),
      ),
    );
  }

  PreferredSizeWidget _buildTransparentAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.only(left: CarboSpacing.x4, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: CarboRadius.mdAll,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: CarboSpacing.x4, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: CarboRadius.mdAll,
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: DeleteButton(),
        ),
      ],
    );
  }

  Widget _bodyWidget(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _heroHeader(context)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            CarboSpacing.x5,
            CarboSpacing.x4,
            CarboSpacing.x5,
            CarboSpacing.x6,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _sectionLabel('Personal Information'),
              const SizedBox(height: CarboSpacing.x3),
              // Swap form card ↔ skeleton based on loading state
              Obx(() => controller.isLoading
                  ? const _FormSkeleton()
                  : _formCard(context)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _heroHeader(BuildContext context) {
    const double totalHeight = _heroHeight + _avatarRadius + 8.0;
    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Hero(
            tag: 'profile_hero_banner',
            child: Container(
              height: _heroHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: CarboGradients.primaryVertical,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(CarboRadius.xxl),
                  bottomRight: Radius.circular(CarboRadius.xxl),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 40,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: _avatarRadius + 24,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Text(
                          Strings.editProfile,
                          textAlign: TextAlign.center,
                          style: CarboTypography.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your personal information',
                          textAlign: TextAlign.center,
                          style: CarboTypography.bodySmall.copyWith(
                            color: Colors.white.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: _heroHeight - _avatarRadius,
            child: Hero(
              tag: 'profile_avatar',
              child: ProfileImagePicker(radius: _avatarRadius),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: CarboTypography.titleMedium.copyWith(
        color: CarboColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _formCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CarboSpacing.x5),
      decoration: BoxDecoration(
        color: CarboColors.surface,
        borderRadius: CarboRadius.lgAll,
        boxShadow: CarboShadow.card,
      ),
      child: ProfileInputWidget(),
    );
  }

  Widget _buttonWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        CarboSpacing.x5,
        CarboSpacing.x3,
        CarboSpacing.x5,
        CarboSpacing.x5,
      ),
      decoration: BoxDecoration(
        color: CarboColors.surface,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(
        () => PrimaryButton(
          title: Strings.update,
          disable: false,
          isLoading: controller.isUpdateLoading,
          onPressed: () {
            controller.updateProfile();
          },
        ),
      ),
    );
  }
}

// ── Pulsing skeleton shown while the API loads ────────────────────────────────
class _FormSkeleton extends StatefulWidget {
  const _FormSkeleton();

  @override
  State<_FormSkeleton> createState() => _FormSkeletonState();
}

class _FormSkeletonState extends State<_FormSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = Tween<double>(begin: 0.35, end: 0.9).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.all(CarboSpacing.x5),
        decoration: BoxDecoration(
          color: CarboColors.surface,
          borderRadius: CarboRadius.lgAll,
          boxShadow: CarboShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: first name + last name
            Row(
              children: [
                Expanded(child: _bar(height: 52)),
                const SizedBox(width: CarboSpacing.x3),
                Expanded(child: _bar(height: 52)),
              ],
            ),
            const SizedBox(height: CarboSpacing.x4),
            _bar(height: 52),                          // country
            const SizedBox(height: CarboSpacing.x4),
            _bar(height: 52),                          // phone
            const SizedBox(height: CarboSpacing.x4),
            Row(
              children: [
                Expanded(child: _bar(height: 52)),     // address
                const SizedBox(width: CarboSpacing.x3),
                Expanded(child: _bar(height: 52)),     // city
              ],
            ),
            const SizedBox(height: CarboSpacing.x4),
            Row(
              children: [
                Expanded(child: _bar(height: 52)),     // state
                const SizedBox(width: CarboSpacing.x3),
                Expanded(child: _bar(height: 52)),     // zip
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar({double height = 16, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: CarboColors.shimmerBase,
        borderRadius: CarboRadius.mdAll,
      ),
    );
  }
}
