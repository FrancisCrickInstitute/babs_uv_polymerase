function start_server() 
    Endpoint("/uv_damage") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/index.html"),String)
    end
    Endpoint("anim_file.json") do request::HTTP.Request
        read(joinpath(@__DIR__, "..//anim_file.json"),String)
    end
    Endpoint("test.json") do request::HTTP.Request
        read(joinpath(@__DIR__, "..//test.json"),String)
    end
    Post("recalculate.json") do request::HTTP.Request
        response = main(String(request.body))
    end
    Pages.start();
end
