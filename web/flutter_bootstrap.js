{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
    onEntrypointLoaded: async function onEntrypointLoaded(engineInitializer) {
        let appRunner = await engineInitializer.initializeEngine({
            hostElement: document.querySelector("#flutterview"),
        });
        await appRunner.runApp();
    },
});
 