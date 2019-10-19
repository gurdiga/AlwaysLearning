require 'open-uri'
require 'json'
require 'pp'

def main
    previous_topic_id = get_json('https://groups.yahoo.com/api/v1/groups/AlwaysLearning/topics')["ygData"]["lastTopic"]

    while previous_topic_id != 0 do
        topic_url = "https://groups.yahoo.com/api/v1/groups/AlwaysLearning/topics/#{previous_topic_id}"
        previous_topic_id = get_json(topic_url, "topic-#{previous_topic_id}.json")["ygData"]["prevTopicId"]
    end
end

def get_json(url, cache_file = nil)
    headers = {
        'Cookie' => 'T=z=2TWqdB2n9udBbjgbD2HmXALNDUzNwY2NjNPMzYwTjYyMTYzND&a=QAE&sk=DAAeEgOsFHVikf&ks=EAAErH4e1IjhafQ3RJAhnPinQ--~G&kt=EAAke8uxkIURy5x1_ZI7NLdzw--~I&ku=FAAv1tO8SJqhX4ngm6AXD4Kyi7_LYtT1RelSC9pCyklXyvOcv63J4LAF4Tf4Mzvl2vHv..VYFGcnTzpKQtIE9oMOe8awj72jT1QQafTHVXcfmbCRAqed0i7mjzxAtI2uzMvZVmT5C7u_Nrzd48SGpI82O46cZtKHN_kfBxpSARuWOk-~A&d=bnMBeWFob28BZwE3NllSTkkzTEdaUFdXU0I3N1FCQkJVT0RPRQFzbAFNekkwTUFFeE1UUTROREUzT1RFMU5qRTBNemM0TVRFLQFhAVFBRQFhYwFBRTI2NnVXXwFsYXQBMlRXcWRCAWNzAQFhbAFndXJkaWdhQGdtYWlsLmNvbQFzYwFkZXNrdG9wX3dlYgFmcwFsTFFSMjU1ZHFXVDIBenoBMlRXcWRCQTdF&af=JnRzPTE1NzEzODI1MTgmcHM9ZWRLd2J4dk5iaXNZckt2VTI2aVRrUS0t; Y=v=1&n=2fqphm0q00cav&l=6kh3860/o&p=m2fvvmd00000000&iz=2062&r=rs&intl=us;'
    }

    basename = cache_file || "#{File.basename(url)}.json"
    file = "cache/#{basename}"

    json = if File.exist?(file) then
        puts "Found cached response for #{url}"
        IO.read(file)
    else
        puts "Fetching #{url}"
        response = open(url, headers).read
        IO.write(file, response)
        response
    end

    JSON.parse(json)
end

main