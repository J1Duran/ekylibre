# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :authorize, :except=>[:login, :logout, :register]
  attr_accessor :current_user
  attr_accessor :current_company
  after_filter :reset_stamper

  def reset_stamper
    User.reset_stamper
  end

  # include Userstamp
    
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery # :secret => '232b3ccf31f8f5fefcbb9d2ac3a00415'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password").  
  # filter_parameter_logging :password

  ADMIN = "administrate"


  def accessible?(url={})
    if url.is_a?(Hash)
      url[:controller]||=controller_name 
      url[:action]||=:index
    end
    if @current_user
      raise Exception.new(url.inspect) if url[:controller].blank? or url[:action].blank?
      if @current_user.admin or session[:rights].include?((User.rights[url[:controller].to_sym]||{})[url[:action].to_sym])
        true
      else
        false
      end
    else
      true
    end
  end
  
  protected  
  
  def render_form(options={})
    a = action_name.split '_'
    @operation    = a[-1].to_sym
    @partial = options[:partial]||a[0..-2].join('_')+'_form'
    @options = options
    begin
      render :template=>options[:template]||'shared/form_'+@operation.to_s
    rescue ActionController::DoubleRenderError
    end
  end

  def search_conditions(options={})
    conditions = ["company_id = ?", @current_company.id]
    keywords = options[:key].to_s.split(" ")
    if keywords.size>0 and options[:attributes].size>0
      conditions[0] += " AND ("
      for attribute in options[:attributes]
        for word in keywords
          conditions[0] += 'LOWER(CAST('+attribute.to_s+" AS VARCHAR)) LIKE ? OR "
          conditions << '%'+word.lower+'%'
        end
      end 
      conditions[0] = conditions[0][0..-5]+")"
    else
      conditions[0] += " AND CAST ('true' AS BOOLEAN)"
    end
    conditions
  end

  def find_and_check(model, id, options={})
    model = model.to_s
    record = model.classify.constantize.find_by_id_and_company_id(id, @current_company.id)
    if record.nil?
      flash[:error] = tg("unavailable.#{model.to_s}", :value=>id)
      redirect_to :action=>options[:url]||model.pluralize
    end
    record
  end



  private
  
  def authorize()
    session[:help_history] ||= []
    if request.get? and not request.xhr? and not [:authentication, :help].include?(controller_name.to_sym)
      session[:last_url] = request.url
    end
    help_search(self.controller_name+'-'+self.action_name) if session[:help] and not [:authentication, :help, :search].include?(controller_name.to_sym)


    begin
      # User.current_user = 
      @current_user = User.find_by_id(session[:user_id]) # User.current_user
      User.stamper = @current_user
      @current_company = @current_user.company
      if session[:last_query].to_i<Time.now.to_i-session[:expiration]
        flash[:error] = tc :expired_session
        redirect_to_login
      else
        session[:last_query] = Time.now.to_i
        session[:history] ||= []
        if request.get? and not request.xhr?
          if request.url == session[:history][1]
            session[:history].delete_at(0)
          elsif request.url != session[:history][0]
            session[:history].insert(0,request.url)
            session[:history].delete_at(127)
          end
        end
      end
    rescue
      reset_session
      redirect_to_login
    end

    session[:rights] ||= []
    if @current_user
      if !@current_user.admin
        if User.rights[params[:controller].to_sym].nil?
          flash[:error]=tc(:no_right_defined_for_this_part_of_the_application)
          redirect_to :controller=>:guide, :action=>:index
        elsif User.rights[params[:controller].to_sym][params[:action].to_sym].nil?
          flash[:error]=tc(:no_right_defined_for_this_part_of_the_application)
          redirect_to :controller=>:guide, :action=>:index
        else
          unless (session[:rights].include?(User.rights[params[:controller].to_sym][params[:action].to_sym]) or session[:rights].include?(ADMIN.to_sym) )
            flash[:error]=tc(:no_right_for_this_part_of_the_application_and_this_user)
            if session[:history]
              redirect_to_back
            else
              redirect_to_login
            end
            return
          end
        end
      end
    end
    
  end

  def help_search(article)
    @article = article
    session[:help_history] << @article if @article != session[:help_history].last
    session[:help]=true
  end

  def redirect_to_login()
    session[:help] = false
    redirect_to :controller=>:authentication, :action=>:login
  end
  
  def redirect_to_back()
    if session[:history][1]
      session[:history].delete_at(0)
      redirect_to session[:history][0]
    else
      redirect_to :back
    end
  end

  def redirect_to_current()
    redirect_to session[:history][0]
  end

end
