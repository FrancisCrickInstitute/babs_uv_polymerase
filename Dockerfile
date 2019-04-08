FROM julia:1.0.1-stretch
WORKDIR /uv_damage
COPY . .
RUN julia -e 'using Pkg;Pkg.add(PackageSpec(url="https://github.com/macroscian/uv_package"))'
EXPOSE 8000
CMD ["julia", "-e", "using uv_damage; uv_damage.start_server()"]
