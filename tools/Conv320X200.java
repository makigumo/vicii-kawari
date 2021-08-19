import java.awt.image.BufferedImage;
import java.awt.Color;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;
import java.io.FileOutputStream;
import java.io.DataOutputStream;
import java.util.HashMap;
import java.util.TreeSet;
import java.util.ArrayList;

public class Conv320X200 {
    static boolean binaryColors = true;

    public static void main(String[] args) throws Exception {

      BufferedImage img = null;
      img = ImageIO.read(new File(args[0]));
      if (args.length > 1 && args[1].equals("-h"))
	      binaryColors = false;
      mapit(img);
    }

    static HashMap<Color,Integer> map = new HashMap<Color,Integer>();

    public static void mapit(BufferedImage img2) throws Exception {

        int height = img2.getHeight();
        int width = img2.getWidth();

	FileOutputStream f = new FileOutputStream(new File("320x200.bin"));
	DataOutputStream dos = new DataOutputStream(f);

	int p=0;
        for (int h=0;h< height;h++) {
          for (int w=0;w< width;w++) {
              Color v = new Color(img2.getRGB(w, h));
	      Integer c = map.get(v);
              if (c == null) { c = new Integer(p); map.put(v,c); p=p+1; }
          }
        }

	if (map.keySet().size() > 16) {
		System.out.println("More than 16 colors");
		System.exit(0);
	}

	for (p=0;p<16;p++) {
	   for (Color col : map.keySet()) {
		if (map.get(col) == p) {
                   int r = col.getRed();
                   int g = col.getGreen();
                   int b = col.getBlue();
                   int r2 = (r >> 2);
                   int g2 = (g >> 2);
                   int b2 = (b >> 2);
                   int v = (r2 << 12) | (g2 << 6) | b2;

		   if (binaryColors) {
                      String s = Integer.toBinaryString(v);
                      while (s.length() < 18) s="0"+s;
                      System.out.println(s+"000000");
		   } else {
                      String s1 = Integer.toHexString(r2);
		      if (s1.length() < 2) s1="0"+s1;
                      String s2 = Integer.toHexString(g2);
		      if (s2.length() < 2) s2="0"+s2;
                      String s3 = Integer.toHexString(b2);
		      if (s3.length() < 2) s3="0"+s3;
		      System.out.println(s1+" "+s2+" "+s3+" 00");
		   }
                }
	    }
	}

	int nhi=0; // upper nibble
	int nlo=0; // lower nibble
        for (int h=0;h< height;h++) {
          for (int w=0;w< width;w=w+2) {
                Color v = new Color(img2.getRGB(w, h));
		int index = map.get(v);
                nhi = index & 0b1111;
                v = new Color(img2.getRGB(w+1, h));
		index = map.get(v);
                nlo = index & 0b1111;
                
                dos.writeByte(nhi << 4 | nlo);
          }
        }
	for (int i=0;i<384*2;i++) {
           dos.writeByte(0);
	}
	dos.close();
    }
}
