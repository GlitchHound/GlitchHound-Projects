import java.io.*;
import java.util.Scanner;

class ProcInputThread implements Runnable
{
	final String newLine;
	Process proc;
	BufferedWriter procInput;
	Scanner inputCommand = new Scanner(System.in);
	String cmd;
	boolean keepWriting = true;

	ProcInputThread(Process procToControl, String lineBreak)
	{
	
		newLine = lineBreak;
		proc = procToControl;
		procInput = new BufferedWriter(new OutputStreamWriter(proc.getOutputStream()));
		
	}
	
	public void setNextCommand(String command)
	{
		try
		{
			cmd = "";
			//if 
			cmd += command;
			cmd += newLine;
			procInput.write(cmd,1,cmd.length()-1);
			procInput.flush();
			
		}catch(Exception e)
		{
			System.out.println(e.toString());
			e.printStackTrace();
			System.out.println("Error in ProcInputThread setNextCommand");
		}
	}
	
	public void stopWriting()
	{
		keepWriting = false;
	}
	
	//Overrides Runnable.run()
	public void run()
	{
	
		//Print all commands since last run.
		try
		{
			while(keepWriting)
			{
				cmd = inputCommand.nextLine();
				cmd += "\n";
				procInput.write(cmd,0,cmd.length());
				procInput.flush();
			}
		}catch(Exception e)
		{
			System.out.println(e.toString());
			e.printStackTrace();
			System.out.println("Error in ProcInputThread run");
		}
	
	}
	

}