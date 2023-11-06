sources = files(
  'application_data.vala',
  'launcher_state.vala',
  'main.vala',
  'service.vala',
)

executable(
  meson.project_name(),
  [resources, sources],
  dependencies: dependencies,
  c_args: [
    '-include', 'config.h'
  ],
  install: true,
)
