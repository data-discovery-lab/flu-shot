import org.json.JSONObject;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.stream.Stream;

public class Main {

    public static void main(String[] args) {
        System.out.println("Hello world : working directory: "  + System.getProperty("user.dir"));

        String fileName = "flu-shot1.json";

        try (Stream<String> stream = Files.lines(Paths.get(fileName))) {
            stream.forEach(l -> processLine(l));
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void processLine(String l) {

        JSONObject obj = new JSONObject(l);

        String text = obj.getString("text");

        System.out.println(text);
    }
}
