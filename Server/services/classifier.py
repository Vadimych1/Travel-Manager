import math

class Classifier:
    def __init__(self):
        self.params = [1, 2, 3, 4, 5]

    def pleasure_process_data(self, activities, days, humans, cost):
        cost = cost/2

        acperday = activities/days
        acperhuman = activities/humans

        costperonce = (cost/10000)/(activities+days)

        acday = 1 if acperday > 0.8 else 0
        achuman = 2 if acperhuman > 0.8 else 1 if acperhuman > 0.4 else 0
        costonce = 1 if costperonce < 0.5 else 0

        return self.params[acday+achuman+costonce]

    def cost_process_data(self, activities, days, humans, cost):
        cost /= 1000

        pleasure = self.pleasure_process_data(activities, days, humans, cost)

        cost/(1+pleasure/5)

        all = activities+days
        costperall = cost/all
        costperday = cost/days
        costperactivity = cost/activities

        costall = 2 if costperall < 20 else 1 if costperall < 40 else 0
        costday = 1 if costperday < 15 else 0
        costactivity = 1 if costperactivity < 25 else 0

        return self.params[costall+costday+costactivity]

if __name__ == "__main__":
    print("Pleasure:", Classifier().pleasure_process_data(1, 3, 3, 32500))
    print("Cost:", Classifier().cost_process_data(1, 3, 3, 32500))