// For prerendering things and caching them
public class Sprites {
    
    PGraphics[] personNodeSprites;

    public Sprites() {

        // Render the person node sprites (10 levels)
        personNodeSprites = new PGraphics[10];

        for (int i = 0; i < personNodeSprites.length; i++) {

            float fillScore = map(i, 0,  personNodeSprites.length - 1, 0, 245);
            float strokeScore = map(i, 0,  personNodeSprites.length - 1, 5, 50);

            personNodeSprites[i] = createGraphics(20, 20);
            personNodeSprites[i].beginDraw();
            personNodeSprites[i].clear();
            personNodeSprites[i].strokeWeight(4);
            personNodeSprites[i].stroke(strokeScore);
            personNodeSprites[i].fill(fillScore);
            personNodeSprites[i].ellipse(10, 10, 15, 15);
            personNodeSprites[i].endDraw();
        }
    }
}