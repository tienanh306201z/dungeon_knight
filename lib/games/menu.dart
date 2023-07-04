import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:dungeon_knight/games/level_1_game.dart';
import 'package:dungeon_knight/games/level_2_game.dart';
import 'package:dungeon_knight/games/level_4_game.dart';
import 'package:dungeon_knight/games/prologue_game.dart';
import 'package:dungeon_knight/util/const.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';

import '../util/localization/strings_location.dart';
import '../util/sounds.dart';
import '../util/sprite_sheet/custom_sprite_animation_widget.dart';
import '../util/sprite_sheet/enemy_sprite_sheet.dart';
import '../util/sprite_sheet/player_sprite_sheet.dart';
import 'level_3_game.dart';
import 'level_5_game.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool showSplash = true;
  int currentPosition = 0;
  late async.Timer _timer;
  List<Future<SpriteAnimation>> sprites = [
    PlayerSpriteSheet.idleRight(),
    EnemySpriteSheet.goblinIdleRight(),
    EnemySpriteSheet.impIdleRight(),
    EnemySpriteSheet.miniBossIdleRight(),
    EnemySpriteSheet.bossIdleRight(),
  ];

  // Disposing
  @override
  void dispose() {
    Sounds.stopBackgroundSound();
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    Future.delayed(const Duration(seconds: 2))
        .whenComplete(() => Sounds.playBackgroundBossSound());
    super.didChangeDependencies();
  }

  // Build Widget
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: showSplash ? buildSplash() : buildMenu(),
    );
  }

  // Menu Screen
  Widget buildMenu() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                getString("title"),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Normal',
                  fontWeight: FontWeight.w700,
                  fontSize: 30.0,
                ),
              ),
              const SizedBox(height: 20.0),
              if (sprites.isNotEmpty)
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CustomSpriteAnimationWidget(
                    animation: sprites[currentPosition],
                  ),
                ),
              const SizedBox(height: 30.0),
              // Play Button .
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    minimumSize: const Size(100, 40),
                  ),
                  child: Text(
                    getString('play_cap'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Normal',
                      fontSize: 17.0,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrologueGame()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30.0),
              Text(
                getString("built_with"),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Normal',
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Splash Screen
  Widget buildSplash() {
    return FlameSplashScreen(
      theme: FlameSplashTheme.dark,
      onFinish: (BuildContext context) {
        setState(() {
          showSplash = false;
        });
        startTimer();
      },
    );
  }

  // Timer for splash screen
  void startTimer() {
    _timer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentPosition++;
        if (currentPosition > sprites.length - 1) {
          currentPosition = 0;
        }
      });
    });
  }
}
