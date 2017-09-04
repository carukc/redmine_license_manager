class RlmLicensesController < ApplicationController
  
  skip_before_filter :require_login, :require_admin
  
  before_filter :check_access_permission
  
  def index
    result = LefService.issue_from_serial_and_checksum(params[:serial], params[:checksum])
    
    if result.nil?
      log_lef_access!('NOT_OK')
      render status: '404', text: 'NOT FOUND'
    elsif result == false  
      log_lef_access!('NOT_OK')
      render_denied
    else
      log_lef_access!('OK')
      render status: '200', text: result.lef
    end  
  end
  
  private
  
  def check_access_permission
    if RlmLefAccessLog.check_if_ip_allowed?(request.ip)
      return true
    else
      render_denied
    end
  end
  
  def log_lef_access!(status = 'OK')
    RlmLefAccessLog.create(ip: request.ip, status: status, request_params: params.to_json)
  end
  
  def render_denied
    render status: '500', text: 'DENIED'
  end
  
end