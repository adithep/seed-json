Package.describe({
  summary: "Add Seed Json Files as Asset and it's control functions."
});

Package.on_use(function (api, where) {
  api.use(['coffeescript', 'core-lib', 'utilities']);
  api.add_files([
    'alpha-entity-json/core_team.json',
    'alpha-entity-json/new_company.json',
    'alpha-entity-json/approaches.json',
    'essential-list-json/_s.json',
    'essential-list-json/keys.json',
    'essential-list-json/locations.json',
    'essential-list-json/location_ty.json',
    'essential-list-json/img.json',
    'web-str-json/_spa.json',
    'web-str-json/_s_to_load.json',
    'web-str-json/paths.json',
    'web-str-json/_tri_btn.json',
    'web-str-json/_tri_banners.json',
    'web-str-json/_tri_s_docs.json',
    'web-str-json/_tri_media.json',
    'web-str-json/_tri_input.json',
    'web-str-json/_tri.json'], 'server', {isAsset: true});
  api.add_files(['json-control/json-control.coffee','_tri_defaults.js'], 'server');
});

Package.on_test(function (api) {
  api.use('seed-json');

  api.add_files('seed-json_tests.js', ['client', 'server']);
});
