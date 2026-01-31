import ProjectDescription

let project = Project(
    name: "MarioSpriteKitDemo",
    organizationName: "iColasoft",
    options: .options(
        defaultKnownRegions: ["en"],
        developmentRegion: "en"
    ),
    settings: Settings.settings(
        base: [
            "DEVELOPMENT_TEAM": "",
            "MARKETING_VERSION": "1.0",
            "CURRENT_PROJECT_VERSION": "1",
            "SWIFT_VERSION": "5.0",
            "TARGETED_DEVICE_FAMILY": "1,2",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    ),
    targets: [
        Target.target(
            name: "MarioSpriteKitDemo",
            destinations: .iOS,
            product: .app,
            bundleId: "com.icolasoft.MarioSpriteKitDemo",
            deploymentTargets: .iOS("14.0"),
            infoPlist: InfoPlist.extendingDefault(with: [
                "UILaunchStoryboardName": "LaunchScreen",
                "UIMainStoryboardFile": "Main",
                "UISupportedInterfaceOrientations": Plist.Value.array([
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight"
                ]),
                "UISupportedInterfaceOrientations~ipad": Plist.Value.array([
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight"
                ]),
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
            settings: Settings.settings(
                base: [
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents": "YES",
                ]
            )
        ),
        Target.target(
            name: "MarioSpriteKitDemoTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.icolasoft.MarioSpriteKitDemoTests",
            deploymentTargets: .iOS("14.0"),
            infoPlist: InfoPlist.default,
            sources: ["MarioSpriteKitDemoTests/**/*.swift"],
            dependencies: [
                .target(name: "MarioSpriteKitDemo")
            ]
        )
    ],
    schemes: [
        Scheme.scheme(
            name: "MarioSpriteKitDemo",
            shared: true,
            buildAction: BuildAction.buildAction(targets: ["MarioSpriteKitDemo"]),
            testAction: TestAction.targets(["MarioSpriteKitDemoTests"]),
            runAction: RunAction.runAction(configuration: "Debug"),
            archiveAction: ArchiveAction.archiveAction(configuration: "Release"),
            profileAction: ProfileAction.profileAction(configuration: "Release"),
            analyzeAction: AnalyzeAction.analyzeAction(configuration: "Debug")
        )
    ]
)
