function start_server()
    open(joinpath(@__DIR__, "../www/anim_file.json"), "w") do f
        anim = main();
        write(f, anim)
    end
    Endpoint("/uv_damage") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/index.html"),String)
    end
    Endpoint("/favicon.ico") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/favicon-wrench.ico"),String)
    end
    Endpoint("/anim_file.json") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/anim_file.json"),String)
    end
    Endpoint("/test.json") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/test.json"),String)
    end
    Endpoint("/recalculate.json", POST) do request::HTTP.Request
        response = main(String(request.body))
    end
    Endpoint("/get_bookmark.json", POST) do request::HTTP.Request
        response = main(String(request.body))
    end
    Endpoint("/tour.js") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/tour.js"),String)
    end
    # local copies of external libraries
    Endpoint("/lib/bootstrap-tourist.js") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/lib/bootstrap-tourist.js"),String)
    end
    Endpoint("/lib/bootstrap-tourist.css") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/lib/bootstrap-tourist.css"),String)
    end
    Endpoint("/lib/jquery-3.4.1.min.js") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/lib/jquery-3.4.1.min.js"),String)
    end
    Endpoint("/lib/popper.min.js") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/lib/popper.min.js"),String)
    end
    Endpoint("/lib/bootstrap.min.js") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/lib/bootstrap.min.js"),String)
    end
    Endpoint("/lib/bootstrap.min.css") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/lib/bootstrap.min.css"),String)
    end
    Endpoint("/lib/d3.v5.min.js") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/lib/d3.v5.min.js"),String)
    end
    Endpoint("/lib/d3-queue.v3.min.js") do request::HTTP.Request
        read(joinpath(@__DIR__, "../www/lib/d3-queue.v3.min.js"),String)
    end
    Pages.start();
end
