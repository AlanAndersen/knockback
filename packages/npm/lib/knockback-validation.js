/*
  knockback-validation.js 0.16.6
  (c) 2011, 2012 Kevin Malakoff - http://kmalakoff.github.com/knockback/
  License: MIT (http://www.opensource.org/licenses/mit-license.php)
  Dependencies: Knockout.js, Backbone.js, and Underscore.js.
*/
(function() {
  return (function(factory) {
    // AMD
    if (typeof define === 'function' && define.amd) {
      return define('knockback-validation', ['underscore', 'backbone', 'knockout', 'knockback'], factory);
    }
    // CommonJS/NodeJS or No Loader
    else {
      return factory.call(this);
    }
  })(function() {// Generated by CoffeeScript 1.3.3
var Backbone, EMAIL_REGEXP, INPUT_RESERVED_IDENTIFIERS, NUMBER_REGEXP, URL_REGEXP, kb, ko, _;

kb = !this.kb && (typeof require !== 'undefined') ? require('knockback') : this.kb;

_ = kb._;

Backbone = kb.Backbone;

ko = kb.ko;

this.Knockback = this.kb = kb;

if (typeof exports !== 'undefined') {
  module.exports = kb;
}

/*
  knockback-validators.js 0.16.6
  (c) 2011, 2012 Kevin Malakoff.
  Knockback.Observable is freely distributable under the MIT license.
  See the following for full license details:
    https://github.com/kmalakoff/knockback/blob/master/LICENSE
*/


URL_REGEXP = /^(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?$/;

EMAIL_REGEXP = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/;

NUMBER_REGEXP = /^\s*(\-|\+)?(\d+|(\d*(\.\d*)))\s*$/;

INPUT_RESERVED_IDENTIFIERS = ['value', 'valueUpdate', 'inject'];

kb.validators = {
  required: function(value) {
    return !!value;
  },
  url: function(value) {
    return !!URL_REGEXP.test(value);
  },
  email: function(value) {
    return !!EMAIL_REGEXP.test(value);
  },
  number: function(value) {
    return !!NUMBER_REGEXP.test(value);
  }
};

kb.valueValidator = function(value, bindings) {
  return ko.dependentObservable(function() {
    var current_value, identifier, results, validator;
    results = {
      valid: true
    };
    current_value = ko.utils.unwrapObservable(value);
    for (identifier in bindings) {
      validator = bindings[identifier];
      results[identifier] = !validator(current_value);
      results.valid &= !results[identifier];
    }
    results.valid = !!results.valid;
    results.invalid = !results.valid;
    return results;
  });
};

kb.inputValidator = function(view_model, el, value_accessor) {
  var $input_el, bindings, identifier, input_name, options, result, skip_attach, type, validator;
  $input_el = $(el);
  if ((input_name = $input_el.attr('name')) && !_.isString(input_name)) {
    input_name = null;
  }
  skip_attach = value_accessor && value_accessor.skip_attach;
  if (!(bindings = $input_el.attr('data-bind'))) {
    return null;
  }
  options = (new Function("sc", "with(sc[0]) { return { " + bindings + " } }"))([view_model]);
  if (!(options && options.value)) {
    return null;
  }
  bindings = {};
  if (kb.validators[type = $input_el.attr('type')]) {
    bindings[type] = kb.validators[type];
  }
  if ($input_el.attr('required')) {
    bindings.required = kb.validators.required;
  }
  for (identifier in options) {
    validator = options[identifier];
    if (!_.contains(INPUT_RESERVED_IDENTIFIERS, identifier) && (typeof validator === 'function')) {
      bindings[identifier] = validator;
    }
  }
  result = kb.valueValidator(options.value, bindings);
  if (input_name && !skip_attach) {
    view_model["$" + input_name] = result;
  }
  return result;
};

kb.formValidator = function(view_model, el) {
  var $root_el, form_name, input_el, name, results, validator, validators, _i, _len, _ref;
  results = {};
  validators = [];
  $root_el = $(el);
  if ((form_name = $root_el.attr('name')) && !_.isString(form_name)) {
    form_name = null;
  }
  _ref = $root_el.find('input');
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    input_el = _ref[_i];
    if (!(name = $(input_el).attr('name'))) {
      continue;
    }
    validator = kb.inputValidator(view_model, input_el, form_name ? {
      skip_attach: true
    } : null);
    !validator || validators.push(results[name] = validator);
  }
  results.valid = ko.dependentObservable(function() {
    var valid, _j, _len1;
    valid = true;
    for (_j = 0, _len1 = validators.length; _j < _len1; _j++) {
      validator = validators[_j];
      valid &= validator().valid;
    }
    return valid;
  });
  results.invalid = ko.dependentObservable(function() {
    return !results.valid();
  });
  if (form_name) {
    view_model["$" + form_name] = results;
  }
  return results;
};
; return kb;});
}).call(this);