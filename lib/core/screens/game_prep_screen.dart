import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_app/core/models/game_models.dart';
import 'package:gather_app/core/providers/game_config_provider.dart';
import 'package:gather_app/l10n/generated/l10n.dart';

class GamePrepScreen extends ConsumerStatefulWidget {
  final GameItem game;
  const GamePrepScreen({super.key, required this.game});

  @override
  ConsumerState<GamePrepScreen> createState() => _GamePrepScreenState();
}

class _GamePrepScreenState extends ConsumerState<GamePrepScreen> {
  // Holds the current state of all configurations for this game
  final Map<String, dynamic> _currentConfigs = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConfigsFromStorage();
    });
  }

  void _loadConfigsFromStorage() {
    final configNotifier = ref.read(gameConfigProvider.notifier);

    // Initialize default values
    setState(() {
      for (var config in widget.game.configs) {
        if (config is SliderConfig) {
          _currentConfigs[config.key] = configNotifier.getConfig(
            widget.game.id,
            config.key,
            config.defaultValue,
          );
        } else if (config is DropdownConfig) {
          _currentConfigs[config.key] = configNotifier.getConfig(
            widget.game.id,
            config.key,
            config.defaultValueBuilder(AppLocalizations.of(context)),
          );
        }
      }
    });
  }

  void _updateConfig(String key, dynamic value) {
    setState(() {
      _currentConfigs[key] = value;
    });
    // Save to SharedPreferences instantly
    ref.read(gameConfigProvider.notifier).setConfig(widget.game.id, key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildHeroAppBar(l10n),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDescription(theme, l10n),
                  const SizedBox(height: 24),
                  if (widget.game.configs.isNotEmpty) ...[
                    _buildConfigPanel(theme, l10n),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStartButton(theme),
    );
  }

  Widget _buildHeroAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 250.0,
      pinned: true,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          widget.game.titleBuilder(l10n),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.game.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(
              widget.game.icon,
              size: 100,
              color: Colors.white.withAlpha(75),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.game.subtitleBuilder(l10n),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.game.descriptionBuilder(l10n),
          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 16),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(128),
            ),
          ),
          child: Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text(
                "How to Play",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: Icon(
                Icons.menu_book_rounded,
                color: theme.colorScheme.primary,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Text(
                    widget.game.rulesBuilder(l10n),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigPanel(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Game Settings",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: widget.game.configs.map((config) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildConfigItem(config, theme, l10n),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigItem(
    GameConfigOption config,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    if (config is SliderConfig) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                config.titleBuilder(l10n),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                _currentConfigs[config.key].toInt().toString(),
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: _currentConfigs[config.key],
            min: config.min,
            max: config.max,
            divisions: config.divisions,
            label: _currentConfigs[config.key].toInt().toString(),
            onChanged: (val) => _updateConfig(config.key, val),
          ),
        ],
      );
    } else if (config is DropdownConfig) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            config.titleBuilder(l10n),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          DropdownButton<String>(
            value: _currentConfigs[config.key],
            borderRadius: BorderRadius.circular(12),
            underline: const SizedBox(),
            onChanged: (val) => _updateConfig(config.key, val!),
            items: config
                .optionsBuilder(l10n)
                .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                .toList(),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildStartButton(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 8,
            shadowColor: theme.colorScheme.primary.withAlpha(128),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                // We inject the user's configurations directly into the game destination!
                builder: (context) => widget.game.gameBuilder(_currentConfigs),
              ),
            );
          },
          child: const Text(
            "START GAME",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
