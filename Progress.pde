
// This is a progress class
class Progress {
    
    float loading_progress;
    float sorting_progress;

    Progress() {
        this.loading_progress = 0;
        this.sorting_progress = 0;
    }

    float getLoadingProgress() {
        return this.loading_progress;
    }

    float getSortingProgress() {
        return this.sorting_progress;
    }

    void setLoadingProgress(float progress) {
        this.loading_progress = progress;
    }

    void setSortingProgress(float progress) {
        this.sorting_progress = progress;
    }
}