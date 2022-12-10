// For prerendering things and caching them
public class Sprites {
    
    PGraphics[] personNodeSprites;

    public Sprites() {

        // Render the person node sprites (10 levels)
        personNodeSprites = new PGraphics[10];

        for (int i = 0; i < personNodeSprites.length; i++) {
            float refreshScore = exp(0.3 * (i - personNodeSprites.length));
            float fillScore = map(refreshScore, 0, 1, 0, 245);
            float strokeScore = map(refreshScore, 0, 1, 5, 50);

            personNodeSprites[i] = createGraphics(20, 20);
            personNodeSprites[i].beginDraw();
            personNodeSprites[i].clear();

            if (i == personNodeSprites.length - 1) {
                personNodeSprites[i].strokeWeight(2);
            } else {
                personNodeSprites[i].strokeWeight(4);
            }
            personNodeSprites[i].stroke(strokeScore);
            personNodeSprites[i].fill(fillScore);
            personNodeSprites[i].ellipse(10, 10, 15, 15);
            personNodeSprites[i].endDraw();
        }
    }
}
