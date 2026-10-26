# Asset and implementation notes

- All factory meshes are Unity primitives or original generated geometry in FactoryWorld.cs.
- No external model, texture or Asset Store assets are needed.
- Nine English voice WAVs were synthesized offline using eSpeak NG via espeakng-loader. The engine is not included in this project. Voice is intentionally basic and replaceable; the complete transcript is provided.
- Hiss and fire crackle audio are generated at runtime from deterministic noise.
- The particle texture is generated in memory. The custom particle shader is included in the scene's serialized references for build retention.
- Standard surface shading and Unity's built-in LegacyRuntime font are used. Unity and its built-in assets remain subject to Unity's terms.
- Environment geometry and the HUD are generated at startup. This prototype has no paid dependency, telemetry, authentication or backend.
- Fire suppression uses raycast hits against three trigger spheres, not particle collisions. Visible spraying alone does not count: aiming, range, stage and charge must pass.
- Navigation arrows point across the open training aisle; this is not an obstacle-aware navigation system. If you change the layout to add obstacles across paths, replace direct arrows with waypoints or NavMesh path guidance.
- Suggested later work: higher-detail imported models, hand animations, authored lightmaps, improved recorded narration and device profiling. These are not included features.
