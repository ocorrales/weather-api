require 'sinatra'
require 'json'
require 'base64'
require 'date'

get '/weather' do
    content_type :json
    {
        temperature: 25,
        humidity: 70,
        condition: "sunn9"
    }.to_json
end

post '/comment' do

    content_type :json

    authentication = authentication(request.env['HTTP_AUTHORIZATION'])
    if authentication != nil
        return authentication
    end

    begin
      request_body = JSON.parse(request.body.read)
    rescue JSON::ParserError
        status 400
        return {error: 'Comment and writer_name are required'}.to_json
    end

    saveCommentToFile(request_body['comment'], request_body['writer'])

    response = {
        comment: request_body['comment'],
        writer: request_body['writer'],
        date: DateTime.now.strftime('%Y-%m-%d'),
        message: "Thank you for your comment #{request_body['writer']}"
}

response.to_json

end

def authenticateUser(username, password)
    return username == "username" && password == "password"
end

def authentication(authHeader)
    unless authHeader
        status 401
        return {error: 'Auth header missing'}.to_json
    end

    unless authHeader.start_with?('Basic ')
        status 401
        return {error: 'Basic authentication required'}.to_json
    end

    encodedCredentials = authHeader.split(' ')[1]
    username, password = Base64.decode64(encodedCredentials).split(':')

    unless authenticateUser(username, password)
        status 401
        return { error: 'Invalid username or password' }.to_json
    end

    return nil
end

def saveCommentToFile(comment, writer)
    File.open('comments.log','a') do |file|
        file.puts("#{Time.now}: #{writer} - #{comment}")
    end
end
