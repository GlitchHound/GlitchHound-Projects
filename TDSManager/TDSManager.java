import java.io.*;

 
public class TDSManager{
		
		public static void main(String args[]) {
 
            try {
				boolean stillAlive = true;
				
                ProcessBuilder builder = new ProcessBuilder("TerrariaServer.exe", "-config", "serverconfig.txt"
				);
				builder.redirectErrorStream(true);
                Process pr = builder.start();
				String lineBreak = System.getProperty("line.separator");
 
                ProcOutputThread thread1 = new ProcOutputThread(pr,lineBreak);
				ProcInputThread thread2 = new ProcInputThread(pr,lineBreak);
				//OutputStreamWriter ctrl = new OutputStreamWriter(pr.getOutputStream());
				
                String[] line=null;
 
				new Thread(thread1).start();
				new Thread(thread2).start();
				
				while(stillAlive)
				{
					line = thread1.nextCommand();
					if (line != null)
					{
						thread2.setNextCommand(line[1]);
						if(line[1].startsWith("/exit"))
						{
							pr.waitFor();
							thread1.stopReading();
							thread2.stopWriting();
							stillAlive = false;
						}
						
					}
				}
				
				System.exit(0);
 
            } catch(Exception e) {
                System.out.println(e.toString());
                e.printStackTrace();
            }
        }
		
}