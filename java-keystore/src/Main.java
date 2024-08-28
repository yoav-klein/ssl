import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.URI;


public class Main {
    
    public static void main(String[] args) throws Exception {
        
        if(args.length < 1) {
            System.out.println("Enter URL");
            System.exit(1);
        }

        String url = args[0];
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder().uri(new URI(url)).build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
        System.out.println(response.statusCode());


    }
}

