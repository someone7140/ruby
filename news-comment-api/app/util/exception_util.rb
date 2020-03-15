module ExceptionUtil

  module_function

  def exceptionHandling(exception, status)
    puts exception
    { status: status }
  end

end
