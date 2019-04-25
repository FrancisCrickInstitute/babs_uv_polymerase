FROM julia:1.0.1-stretch
WORKDIR /uv_damage
COPY . .
RUN julia -e 'using Pkg;Pkg.add(PackageSpec(path="/uv_damage"))'
EXPOSE 8000
CMD ["julia", "-e", "using uv_damage; uv_damage.start_server()"]
