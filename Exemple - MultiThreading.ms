
Global Thread,MainThread,SecondaryThread

Fn WorkThread sender e =
(	
		for i = 1 to Thread.spnLoops.value do 
				(
				If MainThread.CancellationPending Then 
					(
					e.cancel = true
					Thread.lbl2.text = "Primary Thread Aborted"
					)				
						else 
						(
						-- test for object 'Box01'
						--$'Box01'.height = i
						--max zoomext sel				
							
						-- or do some nonsense calculation
						local asum = i*pi
						local prog  = (i as float)/Thread.spnLoops.value * 100			
						--	MainThread.ReportProgress prog asum				
						Thread.lbl2.text = asum as string
						Thread.pb2.value = prog
						sleep 0.05						
					)
					
		
			)				

			Thread.lbl2.text = "Primary Thread Complete"
					Thread.pb2.value = 0 
	
)

Fn WorkThread2 sender e =
(	
				for i = 1 to Thread.spnLoops.value do 
				(
				If SecondaryThread.CancellationPending Then 
					(
					e.cancel = true
					Thread.lbl3.text = "Secondary Thread Aborted"
					)					
					else 
					(
					-- do some nonsense calculation
					local asum = i/pi
					local prog  = (i as float)/Thread.spnLoops.value * 100			
					--	MainThread.ReportProgress prog asum				
					Thread.lbl3.text = asum as string
					Thread.pb3.value = prog
					sleep 0.025							
					)	
	
				)	
				
				Thread.lbl3.text = "Secondary Thread Complete"
				Thread.pb3.value = 0 
				

)

Fn MxsFn =
(	
				for i = 1 to Thread.spnLoops.value do 
				(
				-- test for object 'Box01'
				--	$'Box01'.height = i
				--		max zoomext sel			
					
				-- or do some nonsense calculation
				local asum = i*pi
				local prog  = (i as float)/ Thread.spnLoops.value * 100
				Thread.lbl1.text = asum as string
				Thread.pb1.value = prog
				sleep 0.025			
				)	
				
Thread.lbl1.text = "MXS Fn Complete"
Thread.pb1.value = 0

				
)

Fn UpdateThread sender e =
(	
format "FnValue -  % Percentage done - % \n" e.progresspercentage e.userstate
)

-- Specify the BackgroundWorker Class

--	MainThread = dotnetobject "System.ComponentModel.BackGroundWorker"
MainThread = dotnetobject "CSharpUtilities.SynchronizingBackgroundWorker"

	--	MainThread.WorkerReportsProgress = true
	MainThread.WorkerSupportsCancellation = true		
	dotNet.addEventHandler MainThread "DoWork" WorkThread
	--dotNet.addEventHandler MainThread "ProgressChanged" UpdateThread

--SecondaryThread = dotnetobject "System.ComponentModel.BackGroundWorker"
SecondaryThread =  dotnetobject "CSharpUtilities.SynchronizingBackgroundWorker"

SecondaryThread.WorkerSupportsCancellation = true
	--	SecondaryThread.WorkerReportsProgress = true
	dotNet.addEventHandler SecondaryThread  "DoWork" WorkThread2
	--dotNet.addEventHandler SecondaryThread  "ProgressChanged" UpdateThread
	
rollout Thread "Running Multiple Threads in DotNet" width:728 height:147
(
	GroupBox grp1 "MaxScript Function Execution" pos:[7,28] width:192 height:114
	GroupBox grp2 "DotNet BackgroundWorker Class" pos:[202,7] width:522 height:135
	progressBar pb1 "" pos:[19,88] width:168 height:16 color:(color 255 255 0)
	GroupBox grp3 "Function Value" pos:[18,44] width:171 height:39
	button btnMXstart "Start" pos:[16,110] width:173 height:23
	label lbl1 "" pos:[24,61] width:160 height:18
	progressBar pb2 "" pos:[394,33] width:168 height:25 color:(color 0 255 0)
	GroupBox grp4 "Function Value" pos:[215,22] width:171 height:39
	button btnDNstart "Start Primary" pos:[566,31] width:109 height:28
	label lbl2 "" pos:[220,37] width:161 height:18	
	progressBar pb3 "" pos:[394,70] width:168 height:24 color:(color 30 10 190)
	GroupBox grp18 "Function Value" pos:[215,62] width:170 height:39
	button btnDNboth "Run Both Threads" pos:[214,105] width:461 height:28
	label lbl3 "" pos:[220,78] width:158 height:18
	button btncancel1 "Cancel" pos:[678,31] width:42 height:28		
	button btnDN2 "Start Secondary" pos:[566,67] width:109 height:28
	button btnCancel2 "Cancel" pos:[678,66] width:42 height:28
	spinner spnLoops "Number of Loop Iterations" pos:[114,8] width:84 height:16 range:[10,10000,100] type:#integer
	button btncancelboth "Cancel" pos:[679,104] width:42 height:28

	on Thread open do
	(		
		try
		(
		If MainThread.IsBusy do MainThread.CancelAsync()
		)
		catch()	
	)
	
	on btnDN2 pressed do 
	(
	if not SecondaryThread.IsBusy do SecondaryThread.RunWorkerAsync()
	)
	
	on btnMXstart pressed do	MXSFn()
	
	on btnDNstart pressed do
	(
		if not MainThread.IsBusy do MainThread.RunWorkerAsync()		
	)
	
	on btnDNboth pressed do
	(
		if (not MainThread.IsBusy) and (not SecondaryThread.IsBusy) do
		(
		MainThread.RunWorkerAsync()
		SecondaryThread.RunWorkerAsync()
		)
	)
	
	on btncancel1 pressed do
		If MainThread.IsBusy Then MainThread.CancelAsync()

	on btnDN2 pressed do
		if not SecondaryThread.IsBusy do SecondaryThread.RunWorkerAsync()
	
	on btnCancel2 pressed  do
		If SecondaryThread.IsBusy Then SecondaryThread.CancelAsync()
	
	on btncancelboth pressed  do
	(
	if MainThread.IsBusy do MainThread.CancelAsync()
	if SecondaryThread.IsBusy do SecondaryThread.CancelAsync()
	)
	
)

createdialog thread  style:#(#style_toolwindow, #style_sysmenu) 
