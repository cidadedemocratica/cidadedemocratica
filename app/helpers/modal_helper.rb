module ModalHelper

  # Creates a link tag of the given name using a URL created by the set of
  # options. See the valid options in the documentation for url_for.
  # More in: http://www.wildbit.com/labs/modalbox
  def link_to_modal_box(name, url, options = {})
    # Default.
    modal_options = {
                      :title => 'Cidade Democrática',
                      :loading_string => 'Aguarde...',
                      :with => nil,
                      :transitions => false
                    }

    # before_load - Fires right before loading contents into the
    # ModalBox. If the callback function returns false, content
    # loading will skipped. This can be used for redirecting user
    # to another MB-page for authorization purposes for example.
    #
    # after_load - Fires after loading content into the ModalBox
    # (i.e. after showing or updating existing window).
    #
    # before_hide - Fires right before removing elements from the
    # DOM. Might be useful to get form values before hiding
    # modalbox.
    #
    # after_hide - Fires after hiding ModalBox from the screen.
    #
    # after_resize - Fires after calling resize method.
    #
    # on_show - Fires on first appearing of ModalBox before the
    # contents are being loaded.
    #
    # on_update - Fires on updating the content of ModalBox (on
    # call of Modalbox.show method from active ModalBox instance).

    callbacks = {
                  :before_load => nil,
                  :after_load => nil,
                  :before_hide => nil,
                  :after_hide => nil,
                  :after_resize => nil,
                  :on_show => nil,
                  :on_update => nil
                }

    # Une as opções default com as callbacks.
    modal_options.merge!(callbacks)

    # Sobrescreve as opções default com as do usuário.
    modal_options.merge!(options)

    options = Array.new
    modal_options.each do |key, value|
      if !value.nil?
        if value.is_a?(String)
          options << "#{key.to_s.camelize(:lower)}: \"#{value.to_s}\""
        else
          options << "#{key.to_s.camelize(:lower)}: #{value.to_s}"
        end
      end
    end

    url_do_modal = "'#{url_for(url)}'"
    url_do_modal += ' + ' + modal_options[:with] if modal_options[:with]

    # Escreve o comando javascript que abre o modal.
    # Consulte http://www.wildbit.com/labs/modalbox.
    js = 'Modalbox.show('
    js += "#{url_do_modal}, { "
    js += options.join(', ')
    js += ' })'

    link_to_function name, js, { :title => modal_options[:title] }
  end

end
