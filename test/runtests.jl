using Base.Test
using Gnuplot

function gp_test()
    x = collect(1.:100)

    #-----------------------------------------------------------------
    gp1 = GnuplotProc()
    gp2 = GnuplotProc()
    gp3 = GnuplotProc()

    for i in 1:10
        @gp gp1 "plot sin($i*x)"
        @gp gp2 "plot sin($i*x)"
        @gp gp3 "plot sin($i*x)"
        sleep(0.3)
    end
    GnuplotQuitAll()

    #-----------------------------------------------------------------
    @gp "plot sin(x)"
    @gp "plot sin(x)" "pl cos(x)"
    @gp "plo sin(x)" "s cos(x)"

    @gpi 0 "plot sin(x)"
    @gpi "plot cos(x)" :.


    @gp "plot sin(x)" 2 xr=(-2pi,2pi) "pause 3" "plot cos(4*x)"
    
    x = linspace(-2pi, 2pi, 100);
    y = 1.5 * sin.(0.3 + 0.7x) ;
    noise = randn(length(x))./2;
    e = 0.5 * ones(x);

    @gp x y
    @gp x y "w l"
    @gp x y :aa "plot \$aa w l" "pl \$aa u 1:(2*\$2) w l"

    @gp randn(Float64, 30, 50)

    @gp("set key horizontal", "set grid",
        xrange=(-7,7), ylabel="Y label",
        x, y, "w l t 'Real model' dt 2 lw 2 lc rgb 'red'",
        x, y+noise, e, "w errorbars t 'Data'");

    
    @gpi 0 "f(x) = a * sin(b + c*x); a = 1; b = 1; c = 1;"
    @gpi x y+noise e :aa
    @gpi "fit f(x) \$aa u 1:2:3 via a, b, c;"
    @gpi "set multiplot layout 2,1"
    @gpi "plot \$aa w points" ylab="Data and model"
    @gpi "plot \$aa u 1:(f(\$1)) w lines"
    @gpi 2 xlab="X label" ylab="Residuals"
    @gpi "plot \$aa u 1:((f(\$1)-\$2) / \$3):(1) w errorbars notit"  :.


    #-----------------------------------------------------------------
    @gp("""
        approx_1(x) = x - x**3/6
        approx_2(x) = x - x**3/6 + x**5/120
        approx_3(x) = x - x**3/6 + x**5/120 - x**7/5040
        label1 = "x - {x^3}/3!"
        label2 = "x - {x^3}/3! + {x^5}/5!"
        label3 = "x - {x^3}/3! + {x^5}/5! - {x^7}/7!"
        #
        set termoption enhanced
        save_encoding = GPVAL_ENCODING
        set encoding utf8
        #
        set title "Polynomial approximation of sin(x)"
        set key Left center top reverse
        set xrange [ -3.2 : 3.2 ]
        set xtics ("-π" -pi, "-π/2" -pi/2, 0, "π/2" pi/2, "π" pi)
        set format y "%.1f"
        set samples 500
        set style fill solid 0.4 noborder""",
        "plot '+' using 1:(sin(\$1)):(approx_1(\$1)) with filledcurve title label1 lt 3",
        "plot '+' using 1:(sin(\$1)):(approx_2(\$1)) with filledcurve title label2 lt 2",
        "plot '+' using 1:(sin(\$1)):(approx_3(\$1)) with filledcurve title label3 lt 1",
        "plot sin(x) with lines lw 1 lc rgb 'black'")

    #-----------------------------------------------------------------
    @gp("""
        set zrange [-1:1]
        unset label
        unset arrow
        sinc(u,v) = sin(sqrt(u**2+v**2)) / sqrt(u**2+v**2)
        set xrange [-5:5]; set yrange [-5:5]
        set arrow from 5,-5,-1.2 to 5,5,-1.2 lt -1
        set label 1 "increasing v" at 6,0,-1
        set arrow from 5,6,-1 to 5,5,-1 lt -1
        set label 2 "u=0" at 5,6.5,-1
        set arrow from 5,6,sinc(5,5) to 5,5,sinc(5,5) lt -1
        set label 3 "u=1" at 5,6.5,sinc(5,5)
        set parametric
        set hidden3d offset 0	# front/back coloring makes no sense for fenceplot #
        set isosamples 2,33
        xx=-5; dx=(4.99-(-4.99))/9
        x0=xx; xx=xx+dx
        x1=xx; xx=xx+dx
        x2=xx; xx=xx+dx
        x3=xx; xx=xx+dx
        x4=xx; xx=xx+dx
        x5=xx; xx=xx+dx
        x6=xx; xx=xx+dx
        x7=xx; xx=xx+dx
        x8=xx; xx=xx+dx
        x9=xx; xx=xx+dx""",
        "splot [u=0:1][v=-4.99:4.99]x0, v, (u<0.5) ? -1 : sinc(x0,v) notitle",
	    "splot x1, v, (u<0.5) ? -1 : sinc(x1,v) notitle",
	    "splot x2, v, (u<0.5) ? -1 : sinc(x2,v) notitle",
	    "splot x3, v, (u<0.5) ? -1 : sinc(x3,v) notitle",
	    "splot x4, v, (u<0.5) ? -1 : sinc(x4,v) notitle",
	    "splot x5, v, (u<0.5) ? -1 : sinc(x5,v) notitle",
	    "splot x6, v, (u<0.5) ? -1 : sinc(x6,v) notitle",
	    "splot x7, v, (u<0.5) ? -1 : sinc(x7,v) notitle",
	    "splot x8, v, (u<0.5) ? -1 : sinc(x8,v) notitle",
	    "splot x9, v, (u<0.5) ? -1 : sinc(x9,v) notitle")

    GnuplotQuitAll()
    return true
end

@test gp_test()
