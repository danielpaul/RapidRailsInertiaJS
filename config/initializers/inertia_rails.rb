# frozen_string_literal: true

InertiaRails.configure do |config|
  config.version = ViteRuby.digest
  config.encrypt_history = true

  config.parent_controller = "::InertiaController"

  # Required by the Inertia.js v3 client protocol (see the v3 upgrade guide):
  # serialize the initial page in a <script> element, mark Inertia-managed head
  # tags with `data-inertia`, and always include the errors hash in props.
  config.use_script_element_for_initial_page = true
  config.use_data_inertia_head_attribute = true
  config.always_include_errors_hash = true
end
