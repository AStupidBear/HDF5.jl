function sumloop(x)
    s = 0.0
    @inbounds for i in eachindex(x)
        s += x[i]
    end
    return s
end

for d in 1:3
    for n in (10, 100, 200, 500, 10^7)
        GC.gc(true)
        exp(d * log(n)) * 8 > 1024^3 && continue
        fn = tempname()
        h5open(fn, "w") do fid
            chunk = ntuple(i -> min(n, 100), d)
            x = rand(fill(n, d)...)
            fid["x", "chunk", chunk] = x
        end
        fid = h5open(fn, "r")
        x = HDF5DiskArray(fid["x"])
        sum(read(x.ds)), sumloop(x)
        t_cache = @elapsed s_cache = sumloop(x)
        t_read = @elapsed s_read = sum(read(x.ds))
        # @show n, d, t_cache / t_read
        @test s_read ≈ s_cache
        close(fid)
    end
end