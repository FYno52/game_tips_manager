import 'package:flutter/material.dart';
import 'package:game_tips_manager/screens/start_screen.dart';
import 'package:game_tips_manager/screens/tips_start_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:game_tips_manager/screens/manual.dart';
import 'package:game_tips_manager/screens/map_page.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return const StartScreen();
      },
      routes: <RouteBase>[
        GoRoute(
            path: 'maps',
            name: 'CreateMaps',
            builder: (BuildContext context, GoRouterState state) {
              return const TipsStartScreen();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'ascent',
                name: 'ascent',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'ascent',
                  );
                },
              ),
              GoRoute(
                path: 'breeze',
                name: 'breeze',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'breeze',
                  );
                },
              ),
            ]),
        GoRoute(
          path: 'manual',
          name: 'manualPage',
          builder: (BuildContext contex, GoRouterState state) {
            return const ManualPage();
          },
        )
      ],
    ),
  ],
);
