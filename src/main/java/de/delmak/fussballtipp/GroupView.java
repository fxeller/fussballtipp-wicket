package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Bracket;
import de.delmak.fussballtipp.persistence.BracketStanding;
import java.util.List;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;

@AuthorizeInstantiation("USER")
public class GroupView extends BasePage
{

	public GroupView()
	{
		List brackets = Bracket.getListAll();
		
		ListView rptBrackets = new ListView<Bracket>("rptBrackets", brackets) {

			@Override
			protected void populateItem(ListItem<Bracket> item)
			{
				Bracket bracket = (Bracket) item.getModelObject();
				
				item.add(new Label("lblBracketDescription", new PropertyModel(bracket, "description")));

				ListView rptData = new ListView<BracketStanding>("rptData", BracketStanding.getListByBracketId(bracket.getBracketId()))
					{

						@Override
						protected void populateItem(ListItem item)
						{
							BracketStanding bracketstanding = (BracketStanding)item.getModelObject();
							String scoreSummary = String.format("%d - %d", bracketstanding.getGoalsshot(), bracketstanding.getGoalstaken());

							item.add(new Label("fldTeamDescription", new PropertyModel(bracketstanding, "teamDescription")));
							item.add(new Label("fldPoints", new PropertyModel(bracketstanding, "points")));
							item.add(new Label("fldMatchesPlayed", new PropertyModel(bracketstanding, "matchesplayed")));
							item.add(new Label("fldWins", new PropertyModel(bracketstanding, "wins")));
							item.add(new Label("fldDraws", new PropertyModel(bracketstanding, "draws")));
							item.add(new Label("fldLosses", new PropertyModel(bracketstanding, "losses")));
							item.add(new Label("fldScoreSummary", new Model(scoreSummary)));
							item.add(new Label("fldScoreDiff", new PropertyModel(bracketstanding, "scorediff")));
						}
					};

				item.add(rptData);
			}
		};
		
		add(rptBrackets);
		
	}
}
