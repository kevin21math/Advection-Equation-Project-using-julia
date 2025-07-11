using DelimitedFiles

u0(x) = sin(2π * x)
exact_solution(x, t, a, L) = u0(mod(x - a*t, L))

L = 2.0
a = 1.0
T = 1.0
CFL = 0.5
Nx_vals = [25, 50, 100, 200, 400, 800]

dx_vals = Float64[]
L1_errors = Float64[]
L2_errors = Float64[]
Linf_errors = Float64[]

for Nx in Nx_vals
    dx = L / Nx
    dt = CFL * dx / a
    Nt = Int(floor(T / dt))
    dt = T / Nt  
    x = LinRange(0, L, Nx+1)[1:end-1]
    u = u0.(x)
    u_new = copy(u)

    for n in 1:Nt
      for i in 2:Nx-1
         u_new[i] = u[i] - CFL*(u[i+1] - u[i-1])/2 + (CFL^2)*(u[i+1] - 2*u[i] + u[i-1])/2
      end
      u_new[Nx] = u[Nx] - CFL*(u[1] - u[Nx-1])/2 + (CFL^2)*(u[1] - 2*u[Nx] + u[Nx-1])/2
      u_new[1]  = u[1]  - CFL*(u[2] - u[Nx])/2   + (CFL^2)*(u[2] - 2*u[1] + u[Nx])/2
      u .= u_new
    end

    t = Nt * dt
    exact_u = exact_solution.(x, t, a, L)

    diff = abs.(u .- exact_u)
    L1 = (dx / 3) * (diff[1] + 4 * sum(diff[2:2:end-1]) + 2 * sum(diff[3:2:end-2]) + diff[end])

    diff_sq = (u .- exact_u).^2
    L2_sq = (dx / 3) * (diff_sq[1] + 4 * sum(diff_sq[2:2:end-1]) + 2 * sum(diff_sq[3:2:end-2]) + diff_sq[end])
    L2 = sqrt(L2_sq)

    Linf = maximum(abs.(u - exact_u))

    push!(dx_vals, dx)
    push!(L1_errors, L1)
    push!(L2_errors, L2)
    push!(Linf_errors, Linf)
end

function convergence_rate(errors, dx_vals)
    rates = Any[]
    for i in 1:6
        if i == 1
            push!(rates, "" )  
        else
            rate = log2(errors[i-1]/errors[i])
            push!(rates, rate)
        end
    end
    return rates
end

L1_rates = convergence_rate(L1_errors, dx_vals)
L2_rates = convergence_rate(L2_errors, dx_vals)
Linf_rates = convergence_rate(Linf_errors, dx_vals)

header = ["dx", "L1_error", "L1_rate","L2_error", "L2_rate","Linf_error", "Linf_rate"]
data = [dx_vals L1_errors L1_rates L2_errors L2_rates Linf_errors Linf_rates]
open("lax_wendroff_data.csv", "w") do io
    writedlm(io, [header], ',')
end
open("lax_wendroff_data.csv", "a") do io
    writedlm(io, data, ',')
end

