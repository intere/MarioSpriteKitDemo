import ProjectDescription

let project = Project(
    name: "MarioSpriteKitDemo",
    organizationName: "iColasoft",
    options: .options(
        defaultKnownRegions: ["en"],
        developmentRegion: "en"
    ),
    settings: .settings(
        base: [
            "DEVELOPMENT_TEAM": "",
            "MARKETING_VERSION": "1.0",
            "CURRENT_PROJECT_VERSION": "1",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": "1,2", // iPhone and iPad
        ],
        configurations: [
            .debug(name: "Debug", settings: [:], xcconfig: nil),
            .release(name: "Release", settings: [:], xcconfig: nil)
        ]
    ),
    targets: [
        .target(
            name: "MarioSpriteKitDemo",
            destinations: [.iPhone, .iPad],
            product: .app,
            bundleId: "com.icolasoft.MarioSpriteKitDemo",
            deploymentTargets: .iOS("14.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "UIMainStoryboardFile": "Main",
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight"
                ],
                "UISupportedInterfaceOrientations~ipad": [
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight"
                ],
                "UIStatusBarHidden": true,
                "UIRequiresFullScreen": true,
                "UIViewControllerBasedStatusBarAppearance": false
            ]),
            sources: ["MarioSpriteKitDemo/**/*.swift"],
            resources: [
                "MarioSpriteKitDemo/Assets.xcassets",
                "MarioSpriteKitDemo/Base.lproj/**"
            ],
            dependencies: [],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
                ]
            )
        ),
        .target(
            name: "MarioSpriteKitDemoTests",
            destinations: [.iPhone, .iPad],
            product: .unitTests,
            bundleId: "com.icolasoft.MarioSpriteKitDemoTests",
            deploymentTargets: .iOS("14.0"),
            infoPlist: .default,
            sources: ["MarioSpriteKitDemoTests/**/*.swift"],
            dependencies: [
                .target(name: "MarioSpriteKitDemo")
            ]
        )
    ],
    schemes: [
        .scheme(
            name: "MarioSpriteKitDemo",
            shared: true,
            buildAction: .buildAction(targets: ["MarioSpriteKitDemo"]),
            testAction: .targets(["MarioSpriteKitDemoTests"]),
            runAction: .runAction(configuration: "Debug", executable: "MarioSpriteKitDemo"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release", executable: "MarioSpriteKitDemo"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    ]
)
