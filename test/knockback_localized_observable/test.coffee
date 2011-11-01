$(document).ready( ->
  module("knockback_localized_observable.js")
  test("TEST DEPENDENCY MISSING", ->
    ko.utils; _.VERSION; Backbone.VERSION
  )

  Knockback.locale_manager = new LocaleManager('en', {
    'en':
      formal_hello: 'Hello'
      formal_goodbye: 'Goodbye'
      informal_hello: 'Hi'
      informal_goodbye: 'Bye'
    'en-GB':
      formal_hello: 'Good day sir'
      formal_goodbye: 'Goodbye darling'
      informal_hello: "Let's get a pint"
      informal_goodbye: 'Toodles'
    'fr-FR':
      informal_hello: 'Bonjour'
      informal_goodbye: 'Au revoir'
      formal_hello: 'Bonjour'
      formal_goodbye: 'Au revoir'
  })

  class LocalizedObservable_LocalizedString extends kb.LocalizedObservable
    constructor: (value, options={}, view_model) ->
      return super(value, _.extend(options, {
        read: =>
          localized_string = @getObservedValue(); return '' if not localized_string
          return if (localized_string.string_id) then Knockback.locale_manager.get(localized_string.string_id) else ''
      }), view_model)

  test("Localized greeting", ->
    class ContactViewModelGreeting
      constructor: (model) ->
        @hello = new kb.ModelAttributeObservable(model, {keypath:'hello_greeting', localizer: (value) => return new LocalizedObservable_LocalizedString(value)})
        @goodbye = new kb.ModelAttributeObservable(model, {keypath:'goodbye_greeting', localizer: (value) => return new LocalizedObservable_LocalizedString(value)})
      destroy: ->
        @hello.destroy(); @goodbye.destroy()

    model = new Contact({hello_greeting: new LocalizedString('formal_hello'), goodbye_greeting: new LocalizedString('formal_goodbye')})
    view_model = new ContactViewModelGreeting(model)

    Knockback.locale_manager.setLocale('en')
    equal(view_model.hello(), 'Hello', "en: Hello")
    equal(view_model.goodbye(), 'Goodbye', "en: Goobye")

    Knockback.locale_manager.setLocale('en-GB')
    equal(view_model.hello(), 'Good day sir', "en-GB: Hello")
    equal(view_model.goodbye(), 'Goodbye darling', "en-GB: Goobye")

    Knockback.locale_manager.setLocale('fr-FR')
    equal(view_model.hello(), 'Bonjour', "fr-FR: Hello")
    equal(view_model.goodbye(), 'Au revoir', "fr-FR: Goobye")

    model.set({hello_greeting: new LocalizedString('informal_hello'), goodbye_greeting: new LocalizedString('informal_goodbye')})
    Knockback.locale_manager.setLocale('en')
    equal(view_model.hello(), 'Hi', "en: Hello")
    equal(view_model.goodbye(), 'Bye', "en: Goobye")

    Knockback.locale_manager.setLocale('en-GB')
    equal(view_model.hello(), "Let's get a pint", "en-GB: Hello")
    equal(view_model.goodbye(), 'Toodles', "en-GB: Goobye")

    Knockback.locale_manager.setLocale('fr-FR')
    equal(view_model.hello(), 'Bonjour', "fr-FR: Hello")
    equal(view_model.goodbye(), 'Au revoir', "fr-FR: Goobye")
  )

  class LocalizedObservable_LongDate extends kb.LocalizedObservable
    constructor: (value, options={}, view_model) ->
      return super(value, _.extend(options, {
        read_write: true
        read: =>
          date = @getObservedValue(); return '' if not date
          return Globalize.format(date, 'dd MMMM yyyy', Knockback.locale_manager.getLocale())
        write: (localized_string) =>
          date = @getObservedValue(); return '' if not date
          new_value = Globalize.parseDate(localized_string, 'dd MMMM yyyy', Knockback.locale_manager.getLocale()); return if not new_value
          date.setTime(new_value.valueOf())
      }), view_model)

  test("Date and time with jquery.globalize", ->
    class ContactViewModelDate
      constructor: (model) ->
        @date = new kb.ModelAttributeObservable(model, {keypath:'date', read_write: true, localizer: (value) => return new LocalizedObservable_LongDate(value)}, this)
      destroy: ->
        @date.destroy()

    birthdate = new Date(1940, 10, 9)
    model = new Contact({name: 'John', date: new Date(birthdate.valueOf())})
    view_model = new ContactViewModelDate(model)

    # set from the view model
    Knockback.locale_manager.setLocale('en-GB')
    equal(view_model.date(), '09 November 1940', "John's birthdate in Great Britain format")
    view_model.date('10 December 1963')
    current_date = model.get('date')
    equal(current_date.getFullYear(), 1963, "year is good")
    equal(current_date.getMonth(), 11, "month is good")
    equal(current_date.getDate(), 10, "day is good")

    # set from the model
    model.set({date: new Date(birthdate.valueOf())})
    Knockback.locale_manager.setLocale('fr-FR')
    equal(view_model.date(), '09 novembre 1940', "John's birthdate in France format")
    view_model.date('10 novembre 1940')
    current_date = model.get('date')
    equal(current_date.getFullYear(), 1940, "year is good")
    equal(current_date.getMonth(), 10, "month is good")
    equal(current_date.getDate(), 10, "day is good")
  )

  test("Error cases", ->
    # TODO
  )
)