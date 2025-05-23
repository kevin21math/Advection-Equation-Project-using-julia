#Continuous Periodic Function
# Advection Lax-Wendroff Scheme
# ut + a*ux = 0
# u(x,0) = sin(2πx)

using DelimitedFiles

Nx = 200 
L  = 2  
a  = 1   
T  = 1  
CFL = 0.5

dx = L/Nx                    
dt = CFL*dx/a               
Nt = Int(floor(T/dt))       

x = LinRange(0, L, Nx)

u0(x) = sin(2π*x)
u = u0.(x)
u_new = copy(u)

U = zeros(Nt+1, Nx)
U[1, :] = u

for n in 1:Nt
    for i in 2:Nx-1
        u_new[i] = u[i] - CFL*(u[i+1] - u[i-1])/2 + (CFL^2)*(u[i+1] - 2*u[i] + u[i-1])/2
    end
    u_new[Nx] = u[Nx] - CFL*(u[1] - u[Nx-1])/2 + (CFL^2)*(u[1] - 2*u[Nx] + u[Nx-1])/2
    u_new[1]  = u[1]  - CFL*(u[2] - u[Nx])/2   + (CFL^2)*(u[2] - 2*u[1] + u[Nx])/2
    u .= u_new
    U[n+1, :] = u
end

writedlm("advection_lax_wendroff_data.csv", U, ',')
