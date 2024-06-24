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
                    mapPageName: 'Ascent',
                  );
                },
              ),
              GoRoute(
                path: 'breeze',
                name: 'breeze',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'breeze',
                    mapPageName: 'Breeze',
                  );
                },
              ),
              GoRoute(
                path: 'bind',
                name: 'bind',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'bind',
                    mapPageName: 'Bind',
                  );
                },
              ),
              GoRoute(
                path: 'split',
                name: 'split',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'split',
                    mapPageName: 'Split',
                  );
                },
              ),
              GoRoute(
                path: 'haven',
                name: 'haven',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'haven',
                    mapPageName: 'Haven',
                  );
                },
              ),
              GoRoute(
                path: 'sunset',
                name: 'sunset',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'sunset',
                    mapPageName: 'Sunset',
                  );
                },
              ),
              GoRoute(
                path: 'fracture',
                name: 'fracture',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'fracture',
                    mapPageName: 'Fracture',
                  );
                },
              ),
              GoRoute(
                path: 'lotus',
                name: 'lotus',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'lotus',
                    mapPageName: 'Lotus',
                  );
                },
              ),
              GoRoute(
                path: 'icebox',
                name: 'icebox',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'icebox',
                    mapPageName: 'Icebox',
                  );
                },
              ),
              GoRoute(
                path: 'pearl',
                name: 'pearl',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'pearl',
                    mapPageName: 'Pearl',
                  );
                },
              ),
              GoRoute(
                path: 'abyss',
                name: 'abyss',
                builder: (BuildContext context, GoRouterState state) {
                  return const MapPage(
                    pageId: 'abyss',
                    mapPageName: 'Abyss',
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
