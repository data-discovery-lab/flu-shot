import de.siegmar.fastcsv.writer.CsvAppender;
import de.siegmar.fastcsv.writer.CsvWriter;
import org.apache.commons.lang3.StringEscapeUtils;
import org.json.JSONObject;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.stream.Stream;

public class Main {

    private static File file;
    private static CsvWriter csvWriter = new CsvWriter();
    private static BufferedWriter writer;

    public static void main(String[] args) throws Exception{

        String fileName = "flu-shot.json";
        String outputFile = "flu-shot.converted.csv";



        try (Stream<String> stream = Files.lines(Paths.get(fileName))) {
//            file = new File(outputFile);
             writer = new BufferedWriter( new OutputStreamWriter(new FileOutputStream(outputFile), StandardCharsets.UTF_8));

            // write header
            writer.write("user Id"); // user id
            writer.write(",");
            writer.write("followers_count"); // followers
            writer.write(",");
            writer.write("friends_count"); // friends
            writer.write(",");

            writer.write("tweet"); // tweet
            writer.write(",");
            writer.write("favorite_count"); // favorite_count
            writer.write(",");

            writer.write("created_at"); // created at
            writer.write(",");
            writer.write("state"); // state
            writer.write(",");
            writer.write("country"); // state



            writer.newLine();

            stream.forEachOrdered(l -> processLine(l));

            writer.flush();
            writer.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void processLine(String l) {

        JSONObject obj = new JSONObject(l);

        String text = obj.getString("text");

        String lang = obj.getString("lang");
        if (lang == null || !lang.toLowerCase().equals("en")) {
            return;
        }

        int favorourites_count = obj.getInt("favorite_count");

        try {

            JSONObject user = obj.getJSONObject("user");
            String userLocation = user.getString("location");

            writer.write(user.getString("id_str")); // user id
            writer.write(",");
            writer.write(String.valueOf(user.getInt("followers_count"))); // followers
            writer.write(",");
            writer.write(String.valueOf(user.getInt("friends_count"))); // friends
            writer.write(",");

            writer.write(StringEscapeUtils.escapeCsv(text)); // tweet
            writer.write(",");
            writer.write(String.valueOf(favorourites_count)); // favorite_count
            writer.write(",");
            writer.write(obj.getString("created_at")); // created at

            JSONObject tweetLoc = obj.getJSONObject("geocoded");

            if (tweetLoc != null) {
                writer.write(",");
                writer.write(tweetLoc.optString("state")); // state
                writer.write(",");
                writer.write(tweetLoc.optString("country")); // state
            }


            writer.newLine();

        } catch (IOException e) {
            e.printStackTrace();
        }
        catch (Exception ex) {
            ex.printStackTrace();
        }

        System.out.println(text);
    }
}
