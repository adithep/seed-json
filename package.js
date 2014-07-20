Package.describe({
  summary: "Add Seed Json Files as Asset and it's control functions."
});

Package.on_use(function (api, where) {
  api.use(['coffeescript', 'core-lib', 'utilities']);
  api.add_files([
    'web-str-json/_s.json',
    'web-str-json/_spa.json',
    'web-str-json/keys.json',
    'web-str-json/paths.json',
    'web-str-json/_tri_btn.json',
    'web-str-json/_tri_input.json',
    'web-str-json/_tri.json'], 'server', {isAsset: true});
  api.add_files(['json-control/json-control.coffee','_tri_defaults.js'], 'server');
});

Package.on_test(function (api) {
  api.use('seed-json');

  api.add_files('seed-json_tests.js', ['client', 'server']);
});
