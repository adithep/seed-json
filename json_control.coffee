fs = Npm.require('fs')
path = Npm.require('path')
stream = Npm.require('stream')

class JS

  reseed_json: (schema_n) ->

    if schema_n?
      schema = DATA.findOne(_s_n_for: schema_n)
      if schema?
        ejson = @parse_ejson(schema.json)
      else
        console.log "no schema #{schema_n} avaliable"
        return
      if ejson
        DATA.remove(_s_n: schema_n)
        if schema_n in ["keys", "_s"]
          @dirty_insert(ejson, schema_n)
        else if schema_n is "_tri"
          @_tri_insert(ejson, schema_n)
        else
          @sanitized_insert(
            schema._s_keys
            , ejson
            , schema._s_n_for)
    return

  merge_def: (obj) ->
    def = EJSON.clone(_tri_defaults[obj._tri_ty])
    for key of def
      unless obj[key]
        obj[key] = def[key]
      else
        for akey of def[key]
          unless obj[key][akey]
            obj[key][akey] = def[key][akey]
    return obj

  _tri_insert: (ejson, schema_n) ->
    console.log "seeding #{schema_n}"
    n = 0
    while n < ejson.length
      if _tri_defaults[ejson[n]._tri_ty]?
        obj = @merge_def(ejson[n])
      else
        obj = ejson[n]
      if obj._tri_dis
        tkey = DATA.findOne(_s_n: "keys", key_n: obj._tri_dis)
        if tkey?
          tkey._kid = tkey._id
          delete tkey._id
          delete tkey.key_n
          delete tkey._s_n
          for key of tkey
            obj[key] = tkey[key]
        else
          console.log "cannot find key
            #{obj._tri_dis}
            of #{obj._tri_n}"
      if obj._tri_ty is "input"
        switch obj.key_ty
          when "_dt"
            obj.input_attrs.type = "date"
          else
            obj.input_attrs.type = "text"
        if obj.key_ty is "r_st"
          obj.input_attrs.class = "#{obj.input_attrs.class} input_select"
      obj._s_n = schema_n
      obj._dt = new Date()
      obj._usr = "root"
      DATA.insert(obj)
      n++
    console.log "#{schema_n} seeded"
    return

  dirty_insert: (ejson, schema_n) ->
    n = 0
    while n < ejson.length
      ejson[n]._s_n = schema_n
      ejson[n]._dt = new Date()
      ejson[n]._usr = "root"
      DATA.insert(ejson[n])
      n++

  sanitized_insert: (keys, ejson, schema_n) ->
    console.log "seeding #{schema_n}"
    keys_arr = DATA.find(
      _s_n: "keys"
      , key_n: {$in: keys}
    ).fetch()
    n = 0
    while n < ejson.length
      obj = {}
      n_k = 0
      while n_k < keys_arr.length
        if keys_arr[n_k].key_ty is "now"
          obj[keys_arr[n_k].key_n] = new Date()
        else if keys_arr[n_k].key_ty is "user"
          obj[keys_arr[n_k].key_n] = "root"
        else
          if ejson[n][keys_arr[n_k].key_n]?
            value = @key_check(
              keys_arr[n_k]
              , ejson[n][keys_arr[n_k].key_n]
              , schema_n)
            if value?
              obj[keys_arr[n_k].key_n] = value
            else
              console.log "value mismatched for
                key: #{keys_arr[n_k].key_n}
                , value: #{ejson[n][keys_arr[n_k].key_n]}"
        n_k++
      obj._s_n = schema_n
      DATA.insert(obj)
      n++
    console.log "#{schema_n} seeded"
    return

  parse_ejson: (json) ->
    if json?
      if Array.isArray(json)
        j_n = 0
        ejson = []
        while j_n < json.length
          t_ejson = EJSON.parse(Assets.getText(json[j_n]))
          ejson = ejson.concat(t_ejson)
          j_n++
      else
        ejson = EJSON.parse(Assets.getText(json))
    if ejson? and ejson.length > 0
      return ejson
    else
      console.log "nodata in #{json}"
      return false

  seed_json_detail: ->
    DATA.remove({})
    _s_ejson = EJSON.parse(Assets.getText('_s/_s.json'))
    _s_n = 0
    while _s_n < _s_ejson.length
      DATA.insert(_s_ejson[_s_n])
      if _s_ejson[_s_n]._s_n_for isnt "_s"
        ejson = @parse_ejson(_s_ejson[_s_n].json)
        if ejson
          n = 0
          if _s_ejson[_s_n]._s_n_for is "keys"
            @dirty_insert(ejson, "keys")
          else if _s_ejson[_s_n]._s_n_for is "_tri"
            @_tri_insert(ejson, "_tri")
          else
            @sanitized_insert(
              _s_ejson[_s_n]._s_keys
              , ejson
              , _s_ejson[_s_n]._s_n_for)
      _s_n++

  key_check: (key, value, schema) ->
    if key
      switch key.key_ty
        when "_st"
          if typeof value is "string" and String(value) isnt ""
            return String(value)
        when "_num"
          if typeof value is "number" and Number(value) isnt NaN
            return Number(value)
        when "r_st"
          if key.key_s is schema
            return String(value)
          else
            obj = {}
            obj[key.key_key] = value
            obj._s_n = key.key_s
            if DATA.find(obj).count() is 1
              return String(value)
            else
              console.log "cannot find value
                #{value} for key
                #{key.key_n} for schema
                #{schema} in database"
              return String(value)
        when "r_gr_st"
          return value
        when "_bl"
          if typeof value is "boolean"
            return value
        when "currency"
          if Number(value) isnt NaN
            return Number(value)
        when "phone"
          phone = phone_format.format_number(value)
          if phone
            return phone
        when "email"
          if email_format.reg.test(value)
            return value
        when "geo_json"
          return value
        when "_dt"
          if value instanceof Date
            return value
    false

  printobj: ->
    ejson = EJSON.parse(Assets.getText('countries.json'))
    n = 0
    k = 0
    arr = []
    while n < ejson.length
      for key of ejson[n].translations
        arr[k] = {}
        arr[k].translations = true
        arr[k].trans_country_name = true
        arr[k].string = ejson[n].country_name
        arr[k].language = String(key)
        arr[k].translated_string = ejson[n].translations[key]
        k++
      n++

    h = '../../../../../../packages/seed-json/translations.json'
    fs.writeFileSync(
      h
      , EJSON.stringify(arr, {indent: true})
    )
    console.log arr

  print: (json, type, array, name, arry, conv, cont, json2) ->
    ejson = EJSON.parse(Assets.getText(json))
    if json2
      ejson2 = EJSON.parse(Assets.getText(json2))
    n = 0
    k = 0
    arr = []
    while n < ejson.length
      nn = 0
      while nn < ejson[n][array].length
        arr[k] = {}
        arr[k][type] = true
        arr[k][name] = ejson[n][name]
        if conv and cont
          obj = {}
          obj[conv] = ejson[n][array][nn]
          console.log obj
          if ejson2
            ob = _.findWhere(ejson2, obj)
          else
            ob = _.findWhere(ejson, obj)
          if ob[cont]
            arr[k][arry] = ob[cont]
        else
          arr[k][arry] = ejson[n][array][nn]
        nn++
        k++
      n++
    h = '../../../../../../packages/seed-json/' + type + '.json'
    fs.writeFileSync(
      h
      , EJSON.stringify(arr, {indent: true})
    )
    console.log arr

json_control.js = new JS()
