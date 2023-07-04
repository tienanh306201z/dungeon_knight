import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../util/const.dart';
import '../util/sounds.dart';
import '../util/sprite_sheet/game_sprite_sheet.dart';
import '../util/sprite_sheet/player_sprite_sheet.dart';

class Knight extends SimplePlayer with Lighting, ObjectCollision {
  double attack = 35;
  double stamina = 100;
  double initSpeed = tileSize / 0.25;
  async.Timer? _timerStamina;
  bool containKey = false;
  bool showObserveEnemy = false;
  final String nick;
  late TextPaint _textConfig;
  Vector2 sizeTextNick = Vector2.zero();
  bool canAttack = true;

  Knight(Vector2 position, this.nick)
      : super(
          animation: PlayerSpriteSheet.playerAnimations(),
          size: Vector2.all(tileSize * 0.75),
          position: position,
          life: 250,
          speed: tileSize / 0.2,
        ) {
    _textConfig = TextPaint(
      style: TextStyle(
        fontSize: tileSize / 3,
        color: Colors.white,
      ),
    );
    sizeTextNick = _textConfig.measureText(nick);
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(valueByTileSize(8), valueByTileSize(8)),
            align: Vector2(
              valueByTileSize(4),
              valueByTileSize(8),
            ),
          ),
        ],
      ),
    );

    setupLighting(
      LightingConfig(
        radius: width * 1.5,
        blurBorder: width,
        color: Colors.deepOrangeAccent.withOpacity(0.2),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    _renderNickName(canvas);
    super.render(canvas);
  }

  // Jostick Action while button pressed.
  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      actionAttackSword();
    }

    if (event.id == LogicalKeyboardKey.space.keyId &&
        event.event == ActionEvent.DOWN) {
      actionAttackSword();
    }

    if (event.id == LogicalKeyboardKey.keyZ.keyId &&
        event.event == ActionEvent.DOWN) {
      actionAttackRange();
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      actionAttackRange();
    }
    super.joystickAction(event);
  }

  // Player Action Attack with sword
  void actionAttackSword() {
    if (canAttack) {
      Sounds.attackPlayerMelee();
      simpleAttackMelee(
        damage: attack,
        animationRight: PlayerSpriteSheet.attackEffectRight(),
        size: Vector2.all(tileSize),
      );
      canAttack = false;
      Future.delayed(const Duration(milliseconds: 500))
          .whenComplete(() => canAttack = true);
    }
  }

  // Player Action Attack with Skill
  void actionAttackRange() {
    if (stamina < 25) {
      return;
    }

    Sounds.attackRange();
    decrementStamina(25);
    simpleAttackRange(
      animationRight: GameSpriteSheet.fireBallAttackRight(),
      animationLeft: GameSpriteSheet.fireBallAttackLeft(),
      animationUp: GameSpriteSheet.fireBallAttackTop(),
      animationDown: GameSpriteSheet.fireBallAttackBottom(),
      animationDestroy: GameSpriteSheet.fireBallExplosion(),
      size: Vector2(tileSize * 0.65, tileSize * 0.65),
      damage: 50,
      speed: initSpeed * (tileSize / 32),
      enableDiagonal: false,
      onDestroy: () {
        Sounds.explosion();
      },
      collision: CollisionConfig(
        collisions: [
          CollisionArea.rectangle(size: Vector2(tileSize / 2, tileSize / 2)),
        ],
      ),
      lightingConfig: LightingConfig(
        radius: tileSize * 0.9,
        blurBorder: tileSize / 2,
        color: Colors.deepOrangeAccent.withOpacity(0.4),
      ),
    );
  }

  // Player Dead
  @override
  void die() {
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: Vector2(
          position.x,
          position.y,
        ),
        size: Vector2.all(30),
      ),
    );
    super.die();
  }

  // Updating player
  @override
  void update(double dt) {
    if (isDead) return;
    _verifyStamina();
    seeEnemy(
      radiusVision: tileSize * 6,
      notObserved: () {
        showObserveEnemy = false;
      },
      observed: (enemies) {
        if (showObserveEnemy) return;
        showObserveEnemy = true;
        _showEmote();
      },
    );
    super.update(dt);
  }

  // verify playe stamina
  void _verifyStamina() {
    if (_timerStamina == null) {
      _timerStamina = async.Timer(const Duration(milliseconds: 150), () {
        _timerStamina = null;
      });
    } else {
      return;
    }

    stamina += 2;
    if (stamina > 100) {
      stamina = 100;
    }
  }

  // Showing emote
  void _showEmote({String emote = 'emote/emote_exclamacao.png'}) {
    gameRef.add(
      AnimatedFollowerObject(
        animation: SpriteAnimation.load(
          emote,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.1,
            textureSize: Vector2(32, 32),
          ),
        ),
        target: this,
        size: Vector2(32, 32),
        positionFromTarget: Vector2(18, -6),
      ),
    );
  }

  // Decrement stamina while player using attack
  void decrementStamina(int i) {
    stamina -= i;
    if (stamina < 0) {
      stamina = 0;
    }
  }

  // Receive Damage
  @override
  void receiveDamage(AttackFromEnum attacker, double damage, dynamic identify) {
    if (isDead) return;
    showDamage(
      damage,
      config: TextStyle(
        fontSize: valueByTileSize(5),
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
    super.receiveDamage(attacker, damage, identify);
  }

  void _renderNickName(Canvas canvas) {
    _textConfig.render(
      canvas,
      nick,
      Vector2(
        position.x + ((width - sizeTextNick.x) / 2),
        position.y - sizeTextNick.y - 12,
      ),
    );
  }
}
