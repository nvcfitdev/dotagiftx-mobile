import 'package:dotagiftx_mobile/presentation/core/resources/app_colors.dart';
import 'package:dotagiftx_mobile/presentation/home/states/heroes_state.dart';
import 'package:dotagiftx_mobile/presentation/home/subviews/hero_card_view.dart';
import 'package:dotagiftx_mobile/presentation/home/subviews/shimmer_hero_card_view.dart';
import 'package:dotagiftx_mobile/presentation/home/viewmodels/heroes_cubit.dart';
import 'package:dotagiftx_mobile/presentation/home/viewmodels/home_cubit.dart';
import 'package:dotagiftx_mobile/presentation/shared/localization/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HeroesNavView extends StatefulWidget {
  final void Function(String)? onHeroTap;

  const HeroesNavView({this.onHeroTap, super.key});

  @override
  State<HeroesNavView> createState() => _HeroesNavViewState();
}

class _HeroesNavViewState extends State<HeroesNavView> {
  late ScrollController _scrollController;
  late TextEditingController _searchController;
  bool _isScrolled = false;
  bool _showClearButton = false;

  @override
  Widget build(BuildContext context) {
    final heroesCubit = context.read<HomeCubit>().heroesCubit;
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: BlocBuilder<HeroesCubit, HeroesState>(
          bloc: heroesCubit,
          builder: (context, state) {
            return Text(I18n.of(context).homeNavHeroes(state.heroes.length));
          },
        ),
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        scrolledUnderElevation: 0,
        surfaceTintColor: AppColors.black,
      ),
      body: Column(
        children: [
          // Search Field
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: I18n.of(context).heroesSearchHint,
                hintStyle: const TextStyle(color: AppColors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                suffixIcon:
                    _showClearButton
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _showClearButton = false;
                            });
                            heroesCubit.searchHero('');
                          },
                        )
                        : null,
                filled: true,
                fillColor: AppColors.darkGrey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _showClearButton = value.isNotEmpty;
                });
                heroesCubit.searchHero(value);
              },
            ),
          ),
          // Main content
          Expanded(
            child: BlocBuilder<HeroesCubit, HeroesState>(
              bloc: heroesCubit,
              builder: (context, state) {
                final heroes = state.heroes;
                final itemCount = state.loadingHeroes ? 15 : heroes.length;

                return Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: () async => heroesCubit.onSwipeToRefresh(),
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          if (state.loadingHeroes) {
                            return const ShimmerHeroCardView();
                          }

                          final hero = heroes[index];
                          return HeroCardView(
                            hero: hero,
                            onTap:
                                () => widget.onHeroTap?.call(hero.name ?? ''),
                          );
                        },
                      ),
                    ),
                    // Top shadow when scrolled
                    if (_isScrolled)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.black.withValues(alpha: 0.8),
                                AppColors.black.withValues(alpha: 0.4),
                                AppColors.black.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    _scrollController.addListener(_onScroll);

    // Set search query to the controller as the state is persisting as well
    _searchController.text = context.read<HomeCubit>().heroesCubit.searchQuery;
    _showClearButton = _searchController.text.isNotEmpty;
  }

  void _onScroll() {
    FocusScope.of(context).unfocus();

    final isScrolled =
        _scrollController.hasClients && _scrollController.offset > 0;
    if (isScrolled != _isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }
}
