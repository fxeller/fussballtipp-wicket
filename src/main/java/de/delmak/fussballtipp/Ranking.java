package de.delmak.fussballtipp;

import de.delmak.fussballtipp.persistence.Betgroup;
import de.delmak.fussballtipp.persistence.UserBetScoreAggr;
import de.delmak.fussballtipp.persistence.UserBetgroup;
import java.util.List;
import org.apache.wicket.authroles.authorization.strategies.role.annotations.AuthorizeInstantiation;
import org.apache.wicket.markup.html.basic.Label;
import org.apache.wicket.markup.html.link.BookmarkablePageLink;
import org.apache.wicket.markup.html.list.ListItem;
import org.apache.wicket.markup.html.list.ListView;
import org.apache.wicket.model.Model;
import org.apache.wicket.model.PropertyModel;
import org.apache.wicket.request.mapper.parameter.PageParameters;
import org.apache.wicket.util.string.StringValue;

@AuthorizeInstantiation("USER")
public class Ranking extends BasePage
{
	private final static Integer BET = 5;
	
	private Integer winparts;

	public final Integer getWinparts()
	{
		return winparts;
	}

	public final void setWinparts(Integer winparts)
	{
		this.winparts = winparts;
	}

	private Integer usercount;

	public final Integer getUsercount()
	{
		return usercount;
	}

	public final void setUsercount(Integer usercount)
	{
		this.usercount = usercount;
	}

	public Ranking(final PageParameters parameters)
	{
		List<Betgroup> betgroups = null;
		betgroups = UserBetgroup.getBetgroupsByUserId(UserSession.get().getCurrentUser().getUserId());

		Integer betgroupId;
		
		StringValue paramBetgroupId = parameters.get("betgroupid");
		if (paramBetgroupId.isEmpty() == false)
		{
			betgroupId = paramBetgroupId.toInt();
		}
		else
		{
			betgroupId = betgroups.get(0).getBetgroupId();
		}
				
		ListView rptBetgroupFilter = new ListView<Betgroup>("rptBetgroupFilter", betgroups)
			{

				@Override
				protected void populateItem(ListItem item)
				{
					Betgroup betgroup = (Betgroup) item.getModelObject();

					PageParameters params = new PageParameters();
					params.add("betgroupid", betgroup.getBetgroupId());
					
					BookmarkablePageLink lnkBetgroupFilter = new BookmarkablePageLink("lnkBetgroupFilter", Ranking.class, params);
					lnkBetgroupFilter.add(new Label("lblBetgroupFilter", betgroup.getDescription()));
					lnkBetgroupFilter.add(new BookmarkablePageLinkBehaviour());
					item.add(lnkBetgroupFilter);
				}
			};
		
		rptBetgroupFilter.setVisible(betgroups.size() > 1);
		add(rptBetgroupFilter);

		List userIds = UserBetgroup.getUsersByBetgroupId(betgroupId);
		setWinparts(UserBetScoreAggr.getWinPartsByBetgroupId(betgroupId));
		setUsercount(userIds.size());
		
		ListView rptRanking = new ListView<UserBetScoreAggr>("rptRanking", UserBetScoreAggr.getListByBetgroupId(betgroupId))
			{
				@Override
				protected void populateItem(ListItem item)
				{
					UserBetScoreAggr userBetScore = (UserBetScoreAggr) item.getModelObject();
					String userFullname = String.format("%s %s", userBetScore.getUser().getFirstname(), userBetScore.getUser().getLastname());
					
					Float money = getUsercount().floatValue() * BET.floatValue() / getWinparts().floatValue() * userBetScore.getWinparts().floatValue();
					
					item.add(new Label("fldRank", new PropertyModel(userBetScore, "rank")));
					item.add(new Label("fldUserFullname", new Model(userFullname)));
					item.add(new Label("fldScore", new PropertyModel(userBetScore, "score")));
					item.add(new Label("fldMoney", new Model(money)));
				}
			};
		
		add(rptRanking);
	}

}
