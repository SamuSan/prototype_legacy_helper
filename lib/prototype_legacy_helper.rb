module PrototypeLegacyHelper
  # Creates a button with an onclick event which calls a remote action
  # via XMLHttpRequest
  # The options for specifying the target with :url
  # and defining callbacks is the same as link_to_remote.
  def button_to_remote(name, options = {}, html_options = {})
    button_to_function(name, remote_function(options), html_options)
  end

  # Returns a button input tag with the element name of +name+ and a value (i.e., display text) of +value+
  # that will submit form using XMLHttpRequest in the background instead of a regular POST request that
  # reloads the page.
  #
  #  # Create a button that submits to the create action
  #  #
  #  # Generates: <input name="create_btn" onclick="new Ajax.Request('/testing/create',
  #  #     {asynchronous:true, evalScripts:true, parameters:Form.serialize(this.form)});
  #  #     return false;" type="button" value="Create" />
  #  <%= submit_to_remote 'create_btn', 'Create', :url => { :action => 'create' } %>
  #
  #  # Submit to the remote action update and update the DIV succeed or fail based
  #  # on the success or failure of the request
  #  #
  #  # Generates: <input name="update_btn" onclick="new Ajax.Updater({success:'succeed',failure:'fail'},
  #  #      '/testing/update', {asynchronous:true, evalScripts:true, parameters:Form.serialize(this.form)});
  #  #      return false;" type="button" value="Update" />
  #  <%= submit_to_remote 'update_btn', 'Update', :url => { :action => 'update' },
  #     :update => { :success => "succeed", :failure => "fail" }
  #
  # <tt>options</tt> argument is the same as in form_remote_tag.
  def submit_to_remote(name, value, options = {})
    options[:with] ||= 'Form.serialize(this.form)'

    html_options = options.delete(:html) || {}
    html_options[:name] = name

    button_to_remote(value, options, html_options)
  end

  # Returns a link of the given +name+ that will trigger a JavaScript +function+ using the
  # onclick handler and return false after the fact.
  #
  # The first argument +name+ is used as the link text.
  #
  # The next arguments are optional and may include the javascript function definition and a hash of html_options.
  #
  # The +function+ argument can be omitted in favor of an +update_page+
  # block, which evaluates to a string when the template is rendered
  # (instead of making an Ajax request first).
  #
  # The +html_options+ will accept a hash of html attributes for the link tag. Some examples are :class => "nav_button", :id => "articles_nav_button"
  #
  # Note: if you choose to specify the javascript function in a block, but would like to pass html_options, set the +function+ parameter to nil
  #
  #
  # Examples:
  #   link_to_function "Greeting", "alert('Hello world!')"
  #     Produces:
  #       <a onclick="alert('Hello world!'); return false;" href="#">Greeting</a>
  #
  #   link_to_function(image_tag("delete"), "if (confirm('Really?')) do_delete()")
  #     Produces:
  #       <a onclick="if (confirm('Really?')) do_delete(); return false;" href="#">
  #         <img src="/images/delete.png?" alt="Delete"/>
  #       </a>
  #
  #   link_to_function("Show me more", nil, :id => "more_link") do |page|
  #     page[:details].visual_effect  :toggle_blind
  #     page[:more_link].replace_html "Show me less"
  #   end
  #     Produces:
  #       <a href="#" id="more_link" onclick="try {
  #         $(&quot;details&quot;).visualEffect(&quot;toggle_blind&quot;);
  #         $(&quot;more_link&quot;).update(&quot;Show me less&quot;);
  #       }
  #       catch (e) {
  #         alert('RJS error:\n\n' + e.toString());
  #         alert('$(\&quot;details\&quot;).visualEffect(\&quot;toggle_blind\&quot;);
  #         \n$(\&quot;more_link\&quot;).update(\&quot;Show me less\&quot;);');
  #         throw e
  #       };
  #       return false;">Show me more</a>
  #
  def link_to_function(name, *args, &block)
    html_options = args.extract_options!.symbolize_keys

    function = block_given? ? update_page(&block) : args[0] || ''
    onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
    href = html_options[:href] || '#'

    content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
  end

  # Returns a link to a remote action defined by <tt>options[:url]</tt>
  # (using the url_for format) that's called in the background using
  # XMLHttpRequest. The result of that request can then be inserted into a
  # DOM object whose id can be specified with <tt>options[:update]</tt>.
  # Usually, the result would be a partial prepared by the controller with
  # render :partial.
  #
  # Examples:
  #   # Generates: <a href="#" onclick="new Ajax.Updater('posts', '/blog/destroy/3', {asynchronous:true, evalScripts:true});
  #   #            return false;">Delete this post</a>
  #   link_to_remote "Delete this post", :update => "posts",
  #     :url => { :action => "destroy", :id => post.id }
  #
  #   # Generates: <a href="#" onclick="new Ajax.Updater('emails', '/mail/list_emails', {asynchronous:true, evalScripts:true});
  #   #            return false;"><img alt="Refresh" src="/images/refresh.png?" /></a>
  #   link_to_remote(image_tag("refresh"), :update => "emails",
  #     :url => { :action => "list_emails" })
  #
  # You can override the generated HTML options by specifying a hash in
  # <tt>options[:html]</tt>.
  #
  #   link_to_remote "Delete this post", :update => "posts",
  #     :url  => post_url(@post), :method => :delete,
  #     :html => { :class  => "destructive" }
  #
  # You can also specify a hash for <tt>options[:update]</tt> to allow for
  # easy redirection of output to an other DOM element if a server-side
  # error occurs:
  #
  # Example:
  #   # Generates: <a href="#" onclick="new Ajax.Updater({success:'posts',failure:'error'}, '/blog/destroy/5',
  #   #            {asynchronous:true, evalScripts:true}); return false;">Delete this post</a>
  #   link_to_remote "Delete this post",
  #     :url => { :action => "destroy", :id => post.id },
  #     :update => { :success => "posts", :failure => "error" }
  #
  # Optionally, you can use the <tt>options[:position]</tt> parameter to
  # influence how the target DOM element is updated. It must be one of
  # <tt>:before</tt>, <tt>:top</tt>, <tt>:bottom</tt>, or <tt>:after</tt>.
  #
  # The method used is by default POST. You can also specify GET or you
  # can simulate PUT or DELETE over POST. All specified with <tt>options[:method]</tt>
  #
  # Example:
  #   # Generates: <a href="#" onclick="new Ajax.Request('/person/4', {asynchronous:true, evalScripts:true, method:'delete'});
  #   #            return false;">Destroy</a>
  #   link_to_remote "Destroy", :url => person_url(:id => person), :method => :delete
  #
  # By default, these remote requests are processed asynchronous during
  # which various JavaScript callbacks can be triggered (for progress
  # indicators and the likes). All callbacks get access to the
  # <tt>request</tt> object, which holds the underlying XMLHttpRequest.
  #
  # To access the server response, use <tt>request.responseText</tt>, to
  # find out the HTTP status, use <tt>request.status</tt>.
  #
  # Example:
  #   # Generates: <a href="#" onclick="new Ajax.Request('/words/undo?n=33', {asynchronous:true, evalScripts:true,
  #   #            onComplete:function(request){undoRequestCompleted(request)}}); return false;">hello</a>
  #   word = 'hello'
  #   link_to_remote word,
  #     :url => { :action => "undo", :n => word_counter },
  #     :complete => "undoRequestCompleted(request)"
  #
  # The callbacks that may be specified are (in order):
  #
  # <tt>:loading</tt>::       Called when the remote document is being
  #                           loaded with data by the browser.
  # <tt>:loaded</tt>::        Called when the browser has finished loading
  #                           the remote document.
  # <tt>:interactive</tt>::   Called when the user can interact with the
  #                           remote document, even though it has not
  #                           finished loading.
  # <tt>:success</tt>::       Called when the XMLHttpRequest is completed,
  #                           and the HTTP status code is in the 2XX range.
  # <tt>:failure</tt>::       Called when the XMLHttpRequest is completed,
  #                           and the HTTP status code is not in the 2XX
  #                           range.
  # <tt>:complete</tt>::      Called when the XMLHttpRequest is complete
  #                           (fires after success/failure if they are
  #                           present).
  #
  # You can further refine <tt>:success</tt> and <tt>:failure</tt> by
  # adding additional callbacks for specific status codes.
  #
  # Example:
  #   # Generates: <a href="#" onclick="new Ajax.Request('/testing/action', {asynchronous:true, evalScripts:true,
  #   #            on404:function(request){alert('Not found...? Wrong URL...?')},
  #   #            onFailure:function(request){alert('HTTP Error ' + request.status + '!')}}); return false;">hello</a>
  #   link_to_remote word,
  #     :url => { :action => "action" },
  #     404 => "alert('Not found...? Wrong URL...?')",
  #     :failure => "alert('HTTP Error ' + request.status + '!')"
  #
  # A status code callback overrides the success/failure handlers if
  # present.
  #
  # If you for some reason or another need synchronous processing (that'll
  # block the browser while the request is happening), you can specify
  # <tt>options[:type] = :synchronous</tt>.
  #
  # You can customize further browser side call logic by passing in
  # JavaScript code snippets via some optional parameters. In their order
  # of use these are:
  #
  # <tt>:confirm</tt>::      Adds confirmation dialog.
  # <tt>:condition</tt>::    Perform remote request conditionally
  #                          by this expression. Use this to
  #                          describe browser-side conditions when
  #                          request should not be initiated.
  # <tt>:before</tt>::       Called before request is initiated.
  # <tt>:after</tt>::        Called immediately after request was
  #                          initiated and before <tt>:loading</tt>.
  # <tt>:submit</tt>::       Specifies the DOM element ID that's used
  #                          as the parent of the form elements. By
  #                          default this is the current form, but
  #                          it could just as well be the ID of a
  #                          table row or any other DOM element.
  # <tt>:with</tt>::         A JavaScript expression specifying
  #                          the parameters for the XMLHttpRequest.
  #                          Any expressions should return a valid
  #                          URL query string.
  #
  #                          Example:
  #
  #                            :with => "'name=' + $('name').value"
  #
  # You can generate a link that uses AJAX in the general case, while
  # degrading gracefully to plain link behavior in the absence of
  # JavaScript by setting <tt>html_options[:href]</tt> to an alternate URL.
  # Note the extra curly braces around the <tt>options</tt> hash separate
  # it as the second parameter from <tt>html_options</tt>, the third.
  #
  # Example:
  #   link_to_remote "Delete this post",
  #     { :update => "posts", :url => { :action => "destroy", :id => post.id } },
  #     :href => url_for(:action => "destroy", :id => post.id)
  def link_to_remote(name, options = {}, html_options = nil)
    link_to_function(name, remote_function(options), html_options || options.delete(:html))
  end

  # Observes the field with the DOM ID specified by +field_id+ and calls a
  # callback when its contents have changed. The default callback is an
  # Ajax call. By default the value of the observed field is sent as a
  # parameter with the Ajax call.
  #
  # Example:
  #  # Generates: new Form.Element.Observer('suggest', 0.25, function(element, value) {new Ajax.Updater('suggest',
  #  #         '/testing/find_suggestion', {asynchronous:true, evalScripts:true, parameters:'q=' + value})})
  #  <%= observe_field :suggest, :url => { :action => :find_suggestion },
  #       :frequency => 0.25,
  #       :update => :suggest,
  #       :with => 'q'
  #       %>
  #
  # Required +options+ are either of:
  # <tt>:url</tt>::       +url_for+-style options for the action to call
  #                       when the field has changed.
  # <tt>:function</tt>::  Instead of making a remote call to a URL, you
  #                       can specify javascript code to be called instead.
  #                       Note that the value of this option is used as the
  #                       *body* of the javascript function, a function definition
  #                       with parameters named element and value will be generated for you
  #                       for example:
  #                         observe_field("glass", :frequency => 1, :function => "alert('Element changed')")
  #                       will generate:
  #                         new Form.Element.Observer('glass', 1, function(element, value) {alert('Element changed')})
  #                       The element parameter is the DOM element being observed, and the value is its value at the
  #                       time the observer is triggered.
  #
  # Additional options are:
  # <tt>:frequency</tt>:: The frequency (in seconds) at which changes to
  #                       this field will be detected. Not setting this
  #                       option at all or to a value equal to or less than
  #                       zero will use event based observation instead of
  #                       time based observation.
  # <tt>:update</tt>::    Specifies the DOM ID of the element whose
  #                       innerHTML should be updated with the
  #                       XMLHttpRequest response text.
  # <tt>:with</tt>::      A JavaScript expression specifying the parameters
  #                       for the XMLHttpRequest. The default is to send the
  #                       key and value of the observed field. Any custom
  #                       expressions should return a valid URL query string.
  #                       The value of the field is stored in the JavaScript
  #                       variable +value+.
  #
  #                       Examples
  #
  #                         :with => "'my_custom_key=' + value"
  #                         :with => "'person[name]=' + prompt('New name')"
  #                         :with => "Form.Element.serialize('other-field')"
  #
  #                       Finally
  #                         :with => 'name'
  #                       is shorthand for
  #                         :with => "'name=' + value"
  #                       This essentially just changes the key of the parameter.
  #
  # Additionally, you may specify any of the options documented in the
  # <em>Common options</em> section at the top of this document.
  #
  # Example:
  #
  #   # Sends params: {:title => 'Title of the book'} when the book_title input
  #   # field is changed.
  #   observe_field 'book_title',
  #     :url => 'http://example.com/books/edit/1',
  #     :with => 'title'
  #
  #
  def observe_field(field_id, options = {})
    if options[:frequency] && options[:frequency] > 0
      build_observer('Form.Element.Observer', field_id, options)
    else
      build_observer('Form.Element.EventObserver', field_id, options)
    end
  end

  # Observes the form with the DOM ID specified by +form_id+ and calls a
  # callback when its contents have changed. The default callback is an
  # Ajax call. By default all fields of the observed field are sent as
  # parameters with the Ajax call.
  #
  # The +options+ for +observe_form+ are the same as the options for
  # +observe_field+. The JavaScript variable +value+ available to the
  # <tt>:with</tt> option is set to the serialized form by default.
  def observe_form(form_id, options = {})
    if options[:frequency]
      build_observer('Form.Observer', form_id, options)
    else
      build_observer('Form.EventObserver', form_id, options)
    end
  end

  # Periodically calls the specified url (<tt>options[:url]</tt>) every
  # <tt>options[:frequency]</tt> seconds (default is 10). Usually used to
  # update a specified div (<tt>options[:update]</tt>) with the results
  # of the remote call. The options for specifying the target with <tt>:url</tt>
  # and defining callbacks is the same as link_to_remote.
  # Examples:
  #  # Call get_averages and put its results in 'avg' every 10 seconds
  #  # Generates:
  #  #      new PeriodicalExecuter(function() {new Ajax.Updater('avg', '/grades/get_averages',
  #  #      {asynchronous:true, evalScripts:true})}, 10)
  #  periodically_call_remote(:url => { :action => 'get_averages' }, :update => 'avg')
  #
  #  # Call invoice every 10 seconds with the id of the customer
  #  # If it succeeds, update the invoice DIV; if it fails, update the error DIV
  #  # Generates:
  #  #      new PeriodicalExecuter(function() {new Ajax.Updater({success:'invoice',failure:'error'},
  #  #      '/testing/invoice/16', {asynchronous:true, evalScripts:true})}, 10)
  #  periodically_call_remote(:url => { :action => 'invoice', :id => customer.id },
  #     :update => { :success => "invoice", :failure => "error" }
  #
  #  # Call update every 20 seconds and update the new_block DIV
  #  # Generates:
  #  # new PeriodicalExecuter(function() {new Ajax.Updater('news_block', 'update', {asynchronous:true, evalScripts:true})}, 20)
  #  periodically_call_remote(:url => 'update', :frequency => '20', :update => 'news_block')
  #
  def periodically_call_remote(options = {})
     frequency = options[:frequency] || 10 # every ten seconds by default
     code = "new PeriodicalExecuter(function() {#{remote_function(options)}}, #{frequency})"
     javascript_tag(code)
  end

  protected
    def build_observer(klass, name, options = {})
      if options[:with] && (options[:with] !~ /[\{=(.]/)
        options[:with] = "'#{options[:with]}=' + encodeURIComponent(value)"
      else
        options[:with] ||= 'value' unless options[:function]
      end

      callback = options[:function] || remote_function(options)
      javascript  = "new #{klass}('#{name}', "
      javascript << "#{options[:frequency]}, " if options[:frequency]
      javascript << "function(element, value) {"
      javascript << "#{callback}}"
      javascript << ")"
      javascript_tag(javascript)
    end
end
