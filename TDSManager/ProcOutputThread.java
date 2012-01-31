import java.io.*;
import java.util.ArrayList;
import java.util.LinkedList;

class ProcOutputThread implements Runnable
{
	final String newLine;
	Process proc;
	BufferedReader procOutput;
	char outputChar;
	String outputLine = "";
	String username = null;
	String cmd = null;
	String[] parsed = new String[2];
	int openBrace = -1, closeBrace = -1;
	volatile LinkedList<String[]> commands = new LinkedList<String[]>();
	boolean keepReading = true;

	ProcOutputThread(Process procToRead, String lineBreak)
	{
		newLine = lineBreak;
		proc = procToRead;
		procOutput = new BufferedReader(new InputStreamReader(proc.getInputStream()));

	}
	
	public String[] nextCommand()
	{
		if (commands.size() > 0)
		{
			return commands.remove();
		}
		return null;
	}
	
	public void stopReading()
	{
		keepReading = false;
	}
	
	//Override run() in Runnable.
	public void run()
	{
	
		//Print all output since last run.
		try
		{
			while(keepReading) 
			{
				outputChar = (char) procOutput.read();
				outputLine = outputLine + Character.toString(outputChar);
				System.out.print(outputChar);
				if (outputLine.endsWith(newLine))
				{
					if (outputLine.contains("<"))
					{
						//The line is worth investigating, might be from a player.
						outputLine = sterilize(outputLine);
						if (getPlayerAndCommand(outputLine))
						{
							//The line has been parsed.
							parsed[0] = username;
							parsed[1] = cmd;
							commands.add(parsed);
						}
					}
					outputLine = "";
				}
				if (outputLine.toUpperCase().contains("BACKING UP WORLD FILE"))
				{
					Thread.sleep(50);
				}
			}
		}catch(Exception e)
		{
			System.out.println(e.toString());
			e.printStackTrace();
			System.out.println("Error in ProcOutputThread");
		}
	
	}
	
	public String sterilize(String line)
	{
		line = line.trim();
		if (line.startsWith(":"))
		{
			//Line began as an input prompt.
			line = line.substring(line.indexOf(":")+1).trim();
		}
		return line;
	}
	
	public boolean getPlayerAndCommand(String line)
	{
		if (line.startsWith("<") && line.contains("> "))
		{
			//Definitely player speech.
			closeBrace = line.lastIndexOf("> ");
			username = line.substring(1,closeBrace);
			cmd = line.substring(closeBrace+1).trim();
			if (cmd.startsWith("/"))
			{
				return true;
			}
		}
		return false;
	}

}