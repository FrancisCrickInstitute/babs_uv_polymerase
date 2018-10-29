function start_server() 
    Post("/post") do request::HTTP.Request
        data=JSON.parse(String(request.body))
    end
    Get("/get") do request::HTTP.Request
        params = HTTP.queryparams(HTTP.URI(request.target).query)
        println("Body: $(params)")
        response = JSON.json(params)
    end
    Endpoint("/uv_damage") do request::HTTP.Request
        read("www/index.html",String)
    end
    Endpoint("anim_file.json") do request::HTTP.Request
        read("www/anim_file.json",String)
    end
    Endpoint("test.json") do request::HTTP.Request
        read("www/test.json",String)
    end
    Endpoint("pages.js") do request::HTTP.Request
        read("www/pages.js",String)
    end
    Post("recalculate.json") do request::HTTP.Request
        response = main(String(request.body))
    end
    Pages.start();
end
